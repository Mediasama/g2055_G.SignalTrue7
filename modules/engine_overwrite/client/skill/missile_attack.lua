local SkillBase = Skill.GetType("Base")
local socket = require("socket")
local MissileAttack = Skill.GetType("MissileAttack")
local RayCastHelper = require("client.skill.ray_cast_helper")
MissileAttack.isClick = true
MissileAttack.range = 4
MissileAttack.hurtDistance = World.cfg.MissileAttackHurtDistance or 0.1
local BoyHigh = 1.5

function MissileAttack:setAttackType(attackType)
  self.attackType = attackType
end

function MissileAttack:setIsKickATM(isKickATM)
  self.isKickATM = isKickATM
end

function MissileAttack:setIsRechargeSkill(isRechargeSkill)
  self.isRechargeSkill = isRechargeSkill
end

function MissileAttack:canCast(packet, from)
  return true
end

function MissileAttack:cast(packet, from)
  SkillBase.cast(self, packet, from)
end

function MissileAttack:beginHurt(from)
  self.from = from
  self:castMissile()
end

function MissileAttack:update(isBackSwing)
end

local function getHitPlayer(weaponPos, weaponDirection, length, myPos)
  local resultTable = Me.map:getPhysicsWorld():raycastAll(weaponPos, weaponDirection, length, -1)
  if #resultTable == 0 then
    return
  end
  local obj
  local minLen = 99999
  for i, v in ipairs(resultTable) do
    local target = v.target
    if target.boxType == Define.COLLIDER_BOX_TYPE.HIT_BOX or target.className == "MeshPartClient" then
      local length = Lib.getPosDistance(v.collidePos, myPos)
      if minLen > length then
        obj = v
        minLen = length
      end
    end
  end
  return obj
end

local function filterHitEntity(resultTable, myPos, enemyList, boxType)
  local startIndex = #enemyList + 1
  local count = 0
  for _, hitObj in ipairs(resultTable) do
    if hitObj.target.hitBoxType == boxType and hitObj.target.parentObjID ~= Me.objID then
      local length = Lib.getPosDistance(hitObj.collidePos, myPos)
      local index = startIndex - 1
      for i = startIndex, startIndex + count - 1 do
        local v = enemyList[i]
        local dis = Lib.getPosDistance(v.collidePos, myPos)
        if length < dis then
          break
        end
        index = i
      end
      table.insert(enemyList, index + 1, hitObj)
      count = count + 1
    end
  end
end

function MissileAttack:castMissile()
  local from = self.from
  if not from then
    return
  end
  print("MissileAttack:castMissile()  111111111111")
  local shape = self.collider
  local clonePosition = Vector3.new(-self.colliderOffset.x, -self.colliderOffset.y, -self.colliderOffset.z)
  local rotation = Vector3.new(0, -from:getBodyYaw(), 0)
  Lib.rotate(clonePosition, rotation)
  local pos = from:getPosition() + clonePosition
  local quaternion = Quaternion.rotateAxis({
    x = 0,
    y = -1,
    z = 0
  }, from:getBodyYaw())
  local resultTable = from.map:getPhysicsWorld():overlapShape(shape, pos, quaternion, -1)
  local myPos = from:getPosition()
  local enemyList = {}
  filterHitEntity(resultTable, myPos, enemyList, Define.HIT_BOX_TYPE.BODY)
  filterHitEntity(resultTable, myPos, enemyList, Define.HIT_BOX_TYPE.VEHICLE)
  filterHitEntity(resultTable, myPos, enemyList, Define.HIT_BOX_TYPE.DOOR)
  filterHitEntity(resultTable, myPos, enemyList, Define.HIT_BOX_TYPE.ATM)
  if World.cfg.isShowMeleeBox then
    DebugDraw.instance:setEnabled(true)
    DebugDraw.instance:drawShape(shape, pos, quaternion)
  end
  local isHitDamage
  myPos.y = myPos.y + BoyHigh
  for i, hitObj in ipairs(enemyList) do
    local objID = hitObj.target.parentObjID
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() and entity:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) then
    else
      local weaponDirection = hitObj.collidePos - myPos
      local obj = getHitPlayer(myPos, weaponDirection, 50, myPos)
      if obj and obj.target.parentObjID == objID then
        self:createMissile(from, nil, objID, hitObj, hitObj.target.hitBoxType)
        isHitDamage = true
        break
      end
    end
  end
  if not isHitDamage then
    local offset = Vector3.new(0, 0, self.throw.flyDistance)
    local bodyYaw = from:getBodyYaw()
    local rotation = Vector3.new(0, -bodyYaw, 0)
    Lib.rotate(offset, rotation)
    local pos = from:getPosition() + offset
    local direction = pos - myPos
    local hitObj = RayCastHelper:startRayCast(myPos, direction)
    local endPos = hitObj and hitObj.collidePos or pos
    self:createMissile(from, endPos)
  end
end

function MissileAttack:getTargetPosition(entity)
  local pos = entity:getPosition()
  local offset
  if entity.isPlayer then
    local conf = self.throw.hitPlayerOffset
    offset = Vector3.new(conf[1], conf[2], conf[3])
  elseif entity:cfg().isTrolley then
    local conf = self.throw.hitCarOffset
    offset = Vector3.new(conf[1], conf[2], conf[3])
  elseif entity.getBastionDefenseType and entity:getBastionDefenseType() == Define.Bastion.Defense.Type.Door then
    local conf = self.throw.hitDoorOffset
    offset = Vector3.new(conf[1], conf[2], conf[3])
  else
    return pos
  end
  local rotation = Vector3.new(0, -entity:getRotationYaw(), 0)
  Lib.rotate(offset, rotation)
  pos = pos + offset
  return pos
end

function MissileAttack:createMissile(from, endPos, objID, hitObj, hitBoxType)
  print("MissileAttack:castMissile()  22222")
  local sourcePos = from:getPosition()
  local info, targetPos
  if objID then
    local entity = World.CurWorld:getEntity(objID)
    targetPos = entity:getPosition()
    info = {}
    info.damagePos = hitObj.collidePos
    info.attackObjID = from.objID
    info.weaponId = World.cfg.defaultWeaponID
    info.attackCount = 1
    info.hurtObjID = objID
    info.hurtType = hitBoxType
    info.sourcePos = sourcePos
    info.targetPos = targetPos
    endPos = self:getTargetPosition(entity)
  end
  sourcePos.y = sourcePos.y + BoyHigh
  local missileInfo = {}
  missileInfo.objID = objID
  missileInfo.missileConf = self.throw
  missileInfo.startPos = sourcePos
  missileInfo.endPos = endPos
  missileInfo.gravity = self.throw.gravity
  missileInfo.targetPos = targetPos
  missileInfo.attackObjID = from.objID
  local distance = Lib.getPosDistance(sourcePos, endPos)
  missileInfo.time = distance / self.throw.flySpeed
  Me:sendPacket({
    pid = "MissileDoDamage",
    damageInfo = info,
    missileInfo = missileInfo,
    skillJsonConf = { damage = 99999 }
  })
  if self.throw.throwSound then
    Me:playSoundByKey(self.throw.throwSound)
  end
  if World.cfg.isShowMeleeBox then
    local effectName = "g2055_effect_green_arrow.effect"
    local effect1 = EffectNode.Load(effectName)
    effect1:setLocalPosition(sourcePos)
    local effect2 = EffectNode.Load(effectName)
    effect2:setLocalPosition(endPos)
    World.CurMap:getScene():getRoot():addChild(effect1)
    World.CurMap:getScene():getRoot():addChild(effect2)
  end
end

function MissileAttack:getSkillTime()
  return self.castActionTime
end

function MissileAttack:enterBackSwing()
  if self.logicTimer then
    self.logicTimer()
  end
end

local function checkActionPriority(upperAction)
  if type(upperAction) ~= "string" then
    return true
  end
  if upperAction:find("idle") then
    return true
  end
  return false
end

function MissileAttack:hitBack(dis, target)
  if not dis or dis <= 0 then
    return
  end
  local v = Lib.v3(0, 0, 0)
  if dis ~= 0 then
    v = target:getPosition() - Lib.tov3(self.from:getPosition())
    v.y = 0
    v:normalize()
    v = v * dis
    v.y = dis
  end
  target:doHurtInC(v, 4)
end

function MissileAttack:showHitEffect(hitObj)
  local hitEffect = self.hitEffect
  if hitEffect then
    local scale = hitEffect.scale and Lib.v3(hitEffect.scale[1], hitEffect.scale[2], hitEffect.scale[3]) or Lib.v3(1, 1, 1)
    local weaponPos = Lib.copy(hitObj.collidePos)
    if hitEffect.offset then
      local clonePosition = Vector3.new(hitEffect.offset[1], hitEffect.offset[2], hitEffect.offset[3])
      local rotation = Vector3.new(-self.from:getRotationPitch(), -self.from:getRotationYaw(), -self.from:getRotationRoll())
      Lib.rotate(clonePosition, rotation)
      weaponPos = weaponPos + clonePosition
    end
    Blockman.instance:playEffectByPos(hitEffect.effect, weaponPos, 0, hitEffect.time, scale)
    local hitEffectData = {
      objID = self.from.objID,
      effect = hitEffect.effect,
      pos = weaponPos,
      time = hitEffect.time
    }
    Me:sendPacket({
      pid = "BulletEffect",
      hitEffectData = hitEffectData,
      bulletEffectData = nil
    })
  end
end

function MissileAttack:leave()
  self.from = nil
  self.hurtObjTick = {}
  if self.debugColliderNode then
    local parent = World.CurMap:getScene():getRoot()
    parent:removeChild(self.debugColliderNode)
  end
end

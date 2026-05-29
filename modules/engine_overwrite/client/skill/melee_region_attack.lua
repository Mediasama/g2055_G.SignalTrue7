local SkillBase = Skill.GetType("Base")
local socket = require("socket")
local MeleeRegionAttack = Skill.GetType("MeleeRegionAttack")
MeleeRegionAttack.isClick = true
MeleeRegionAttack.range = 4
MeleeRegionAttack.hurtDistance = World.cfg.MeleeRegionAttackHurtDistance or 0.1

function MeleeRegionAttack:addAttackCollider(from)
  local collider = Instance.Create("CollisionObject")
  collider:setShape(self.collider)
  collider:setCanBlockCamera(false)
  local clonePosition = Vector3.new(-self.colliderOffset.x, -self.colliderOffset.y, -self.colliderOffset.z)
  local rotation = Vector3.new(0, -from:getBodyYaw(), 0)
  Lib.rotate(clonePosition, rotation)
  local pos = from:getPosition() + clonePosition
  collider:setLocalPosition(pos)
  collider.xxx = 12345
  collider:setCollisionGroup(Define.COLLISION_GROUP.PLAYER)
  local parent = World.CurMap:getScene():getRoot()
  parent:addChild(collider)
  self.debugColliderNode = collider
end

function MeleeRegionAttack:setAttackType(attackType)
  self.attackType = attackType
end

function MeleeRegionAttack:setIsKickATM(isKickATM)
  self.isKickATM = isKickATM
end

function MeleeRegionAttack:setIsRechargeSkill(isRechargeSkill)
  self.isRechargeSkill = isRechargeSkill
end

function MeleeRegionAttack:onCollision(target, typename)
  if typename ~= "Entity" then
    return
  end
  print("info.target", target.isPlayer, target.objID)
  if target.isPlayer and target.objID ~= self.entity.objID then
    self.entity:sendPacket({
      pid = "BulletDoDamage",
      damageInfo = {},
      pos = target.collidePos,
      fromID = self.entity.objID,
      toID = target.objID,
      sourcePos = self.entity:getPosition(),
      hurtCount = 1,
      rate = 1,
      hurtValue = self.damage
    })
  end
end

function MeleeRegionAttack:onCollisionExit(target)
end

function MeleeRegionAttack:canCast1(packet, from)
  print("MeleeAttack:canCast")
  local curTime = socket.gettime()
  if not self.lastCastTime or curTime - self.lastCastTime >= self.cdTime * 0.05 then
    return true
  end
  return false
end

function MeleeRegionAttack:doCastClient1(packet, from)
  local curTime = socket.gettime()
  if not self.lastCastTime or curTime - self.lastCastTime >= self.cdTime * 0.05 then
    print("client MeleeRegionAttack:cast")
    self.entity = from
    self:addAttackCollider(from)
    self.lastCastTime = curTime
  end
end

function MeleeRegionAttack:canCast(packet, from)
  return true
end

function MeleeRegionAttack:cast(packet, from)
  SkillBase.cast(self, packet, from)
end

function MeleeRegionAttack:beginHurt(from)
  self.from = from
  self.hurtObjTick = {}
  self.isHurtNpc = false
end

function MeleeRegionAttack:update(isBackSwing)
  local from = self.from
  if not from or isBackSwing then
    return
  end
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
  if World.cfg.isShowMeleeBox then
    DebugDraw.instance:setEnabled(true)
    DebugDraw.instance:drawShape(shape, pos, quaternion)
  end
  local enemyList = {}
  local teamList = {}
  local notPlayerList = {}
  local parent = World.CurMap:getScene():getRoot()
  self.isHurtTarget = false
  for i, hitObj in ipairs(resultTable) do
    if hitObj.target.isPlayer then
      local objID = hitObj.target.objID
      if objID == Me.objID then
      elseif from.isSameGang and from:isSameGang(hitObj.target) then
        table.insert(teamList, hitObj)
      else
        table.insert(enemyList, hitObj)
      end
    elseif hitObj.target.boxType == Define.COLLIDER_BOX_TYPE.HIT_BOX and hitObj.target.hitBoxType > Define.HIT_BOX_TYPE.LIMB then
      local objID = hitObj.target.parentObjID
      if objID ~= from.objID then
        table.insert(notPlayerList, hitObj)
      end
    elseif hitObj.target.guideEnemy and not self.isHurtNpc then
      local guideEnemy = hitObj.target.guideEnemy
      guideEnemy:onHit(self.isRechargeSkill)
      self.isHurtNpc = true
    end
  end
  local hurtPlayerList = enemyList
  if self.attackType == Define.CHARACTER_ATTACK_TYPE.TEAM then
    hurtPlayerList = teamList
  end
  local soundKey = ""
  for i, hitObj in ipairs(hurtPlayerList) do
    local objID = hitObj.target.objID
    self:onHurt(objID, hitObj, from, Define.HIT_BOX_TYPE.BODY)
    soundKey = self.hitPlayerSound
    if hitObj.target:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or hitObj.target:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) then
    else
      self:hitBack(2, hitObj.target)
      self:showHitEffect(hitObj)
    end
  end
  for i, hitObj in ipairs(notPlayerList) do
    local objID = hitObj.target.parentObjID
    self:onHurt(objID, hitObj, from, hitObj.target.hitBoxType)
  end
  if soundKey ~= "" and self.isHurtTarget then
    Me:playSoundByKey(soundKey)
  end
end

function MeleeRegionAttack:onHurt(objID, hitObj, from, hurtType)
  local curTick = World.CurWorld:getTickCount()
  if not self.hurtObjTick then
    return
  end
  local lastTick = self.hurtObjTick[objID] or 0
  if curTick - lastTick > self.cd then
    local entity = World.CurWorld:getEntity(objID)
    local targetPos = entity:getPosition()
    local info = {}
    info.damagePos = hitObj.collidePos
    info.attackObjID = from.objID
    info.weaponId = World.cfg.defaultWeaponID
    info.attackCount = 1
    info.hurtObjID = objID
    info.hurtType = hurtType
    info.sourcePos = from:getPosition()
    info.targetPos = targetPos
    info.isKickATM = self.isKickATM
    Me:sendPacket({
      pid = "BulletDoDamage",
      damageInfo = info
    })
    self.hurtObjTick[objID] = curTick
    self.isHurtTarget = true
  end
end

function MeleeRegionAttack:getSkillTime()
  return self.castActionTime
end

function MeleeRegionAttack:enterBackSwing()
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

function MeleeRegionAttack:hitBack(dis, target)
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

function MeleeRegionAttack:showHitEffect(hitObj)
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

function MeleeRegionAttack:leave()
  self.from = nil
  self.hurtObjTick = {}
  if self.debugColliderNode then
    local parent = World.CurMap:getScene():getRoot()
    parent:removeChild(self.debugColliderNode)
  end
end

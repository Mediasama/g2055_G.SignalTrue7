local Melee = Lib.class("Melee")
local WeaponConfig = T(Config, "WeaponConfig")
local socket = require("socket")

function Melee:ctor(owner, id)
  self.owner = owner
  self.id = id
  self:init()
end

function Melee:init()
  self.cfg = WeaponConfig:getCfgById(self.id)
  self.jsonCfg = WeaponConfig:getWeaponJsonById(self.id)
end

function Melee:initAction()
  print("Melee:initAction()")
  local action = self.jsonCfg.action
  if not action then
    return
  end
  print("=============Melee:initAction()", action.idle)
  local curHp = self.owner:getCurHp()
  if 0 < curHp then
    self.owner:setActionMapping("idle", action.idle)
    self.owner:setActionMapping("run", action.run)
    self.owner:sendPacket({
      pid = "initPlayerAction",
      idle = action.idle,
      run = action.run
    })
  end
end

function Melee:clearAction()
  self.owner:setActionMapping("idle", "idle")
  self.owner:setActionMapping("run", "run")
end

function Melee:release()
end

function Melee:getType()
  return self.cfg.type
end

function Melee:getCfgID()
  return self.cfg.id
end

function Melee:getCfg()
  return self.cfg
end

function Melee:autoFire()
end

function Melee:openFire()
  return true
end

function Melee:closeFire()
end

function Melee:getLauncher()
end

function Melee:getIsAutoAim()
end

function Melee:getIsAutoFire()
end

function Melee:isMelee()
  return true
end

function Melee:playAction(actionName, time)
  time = time or -1
  self.owner:sendPacket({
    pid = "playerAction",
    actionName = actionName,
    time = time
  })
  self.owner:updateUpperAction(actionName, time)
end

function Melee:getWeaponPlayerYaw()
  return 0
end

function Melee:checkAttackHurt()
  local attackType = Define.CHARACTER_ATTACK_TYPE.OBJECT
  print("Melee:checkAttackHurt()")
  local shape = self.jsonCfg.collider
  local clonePosition = Vector3.new(-self.jsonCfg.colliderOffset.x, -self.jsonCfg.colliderOffset.y, -self.jsonCfg.colliderOffset.z)
  local rotation = Vector3.new(-self.owner:getRotationPitch(), -self.owner:getRotationYaw(), -self.owner:getRotationRoll())
  Lib.rotate(clonePosition, rotation)
  local pos = self.owner:getPosition() + clonePosition
  local quaternion = Quaternion.rotateAxis({
    x = 0,
    y = -1,
    z = 0
  }, self.owner:getRotationYaw())
  local resultTable = self.owner.map:getPhysicsWorld():overlapShape(shape, pos, quaternion, -1)
  local enemyList = {}
  local teamList = {}
  local notPlayerList = {}
  for i, hitObj in ipairs(resultTable) do
    if hitObj.target.isPlayer then
      local objID = hitObj.target.objID
      if objID == self.owner.objID then
      elseif self.owner:isSameGang(hitObj.target) then
        table.insert(teamList, hitObj)
      else
        table.insert(enemyList, hitObj)
      end
    elseif hitObj.target.boxType == Define.COLLIDER_BOX_TYPE.HIT_BOX and hitObj.target.hitBoxType > Define.HIT_BOX_TYPE.LIMB then
      print("function Melee:onCollision(hitObj)", hitObj.target.hitBoxType)
      local objID = hitObj.target.parentObjID
      if objID ~= self.owner.objID then
        table.insert(notPlayerList, hitObj)
      end
    end
  end
  local hurtPlayerList = enemyList
  if #enemyList == 0 then
    attackType = Define.CHARACTER_ATTACK_TYPE.TEAM
    hurtPlayerList = teamList
    if #teamList == 0 then
      attackType = Define.CHARACTER_ATTACK_TYPE.OBJECT
    end
  else
    attackType = Define.CHARACTER_ATTACK_TYPE.ENEMY
  end
  local isTeabag
  for i, hitObj in ipairs(enemyList) do
    if hitObj.target.checkIsState and (hitObj.target:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or hitObj.target:checkIsState(Define.CHARACTER_STATE_TYPE.DIE)) then
      isTeabag = true
    end
  end
  if not isTeabag and 0 < #notPlayerList then
    for i, hitObj in ipairs(notPlayerList) do
      if hitObj.target.checkIsState and (hitObj.target:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or hitObj.target:checkIsState(Define.CHARACTER_STATE_TYPE.DIE)) then
        isTeabag = true
      end
    end
  end
  local skillName = self.jsonCfg.skill.idle
  local stateIndex = 0
  local curSkillIndex = 1
  local isRecharge
  if self.owner:getIsRechargeFull() then
    skillName = self.jsonCfg.skill.charge
    isRecharge = true
    stateIndex = 1
  elseif isTeabag then
    skillName = self.jsonCfg.skill.teabag
    stateIndex = 2
  elseif self.owner.isMoving then
    skillName = self.jsonCfg.skill.run
    stateIndex = 3
  elseif not self.owner.onGround then
    skillName = self.jsonCfg.skill.jump
    stateIndex = 4
  end
  self.lastCastIndex = self.lastCastIndex or 0
  if stateIndex == self.lastStateIndex then
    local len = #skillName
    curSkillIndex = self.lastCastIndex % len + 1
  end
  if type(skillName) == "table" then
    skillName = skillName[curSkillIndex]
  end
  print("skillName=", skillName, curSkillIndex)
  self.lastCastIndex = curSkillIndex
  self.lastStateIndex = stateIndex
  skillName = "myplugin/" .. skillName
  return attackType, skillName, isRecharge
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

function Melee:hitBack(dis, target)
  if not dis or dis <= 0 then
    return
  end
  local v = Lib.v3(0, 0, 0)
  if dis ~= 0 then
    v = target:getPosition() - Lib.tov3(self.owner:getPosition())
    v.y = 0
    v:normalize()
    v = v * dis
    v.y = dis
  end
  target:doHurtInC(v, 4)
  local cfg = target:cfg()
  local upperAction = target:getBaseAction()
  local hurtAction = cfg.hurtAction
  local action = hurtAction and hurtAction.action
  if action and action ~= "" and checkActionPriority(upperAction) then
    target:updateUpperAction(action, hurtAction.time, false)
  end
end

function Melee:showHitEffect(hitObj)
  local hitEffect = self.jsonCfg.hitEffect
  if hitEffect then
    local scale = hitEffect.scale and Lib.v3(hitEffect.scale[1], hitEffect.scale[2], hitEffect.scale[3]) or Lib.v3(1, 1, 1)
    local weaponPos = Lib.copy(hitObj.collidePos)
    if hitEffect.offset then
      local clonePosition = Vector3.new(hitEffect.offset[1], hitEffect.offset[2], hitEffect.offset[3])
      local rotation = Vector3.new(-self.owner:getRotationPitch(), -self.owner:getRotationYaw(), -self.owner:getRotationRoll())
      Lib.rotate(clonePosition, rotation)
      weaponPos = weaponPos + clonePosition
    end
    Blockman.instance:playEffectByPos(hitEffect.effect, weaponPos, 0, hitEffect.time, scale)
    local hitEffectData = {
      objID = self.owner.objID,
      effect = hitEffect.effect,
      pos = weaponPos,
      time = hitEffect.time
    }
    self.owner:sendPacket({
      pid = "BulletEffect",
      hitEffectData = hitEffectData,
      bulletEffectData = nil
    })
  end
end

function Melee:getCastActionAndTime()
  local chargeAction = self.jsonCfg.chargeAction
  return chargeAction.castAction, chargeAction.castTime
end

function Melee:getChargeAction()
  return self.jsonCfg.chargeAction
end

function Melee:updateCamera()
  local CameraManager = T(Lib, "CameraManager")
  CameraManager:freeView(self.jsonCfg.camera)
end

function Melee:getMoveSpeed()
  return self.jsonCfg.moveSpeed, self.jsonCfg.moveAcc
end

function Melee:getChargeSkill()
  return self.jsonCfg.skill.charge
end

return Melee

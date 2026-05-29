local Weapon = Lib.class("Weapon")
local WeaponConfig = T(Config, "WeaponConfig")
local WeaponSpread = require("client.weapon_spread")
local SoundConfig = T(Config, "SoundConfig")
local RayTestHelper = require("client.ray_test_helper")
local WeaponEffectHelper = require("client.effect.weapon_effect_helper")
local socket = require("socket")

function Weapon:ctor(owner, id)
  self.owner = owner
  self.id = id
  self.lastFireTime = 0
  self.lastShakeTime = 0
  self.fireTimerList = {}
  self:init()
  self.lifeTime = 0
  self.reloadTime = 0
  self.isStopFire = true
end

function Weapon:init()
  self.cfg = WeaponConfig:getCfgById(self.id)
  self.jsonCfg = WeaponConfig:getWeaponJsonById(self.id)
  self.actionCfg = self.jsonCfg.launcher.action
  local launchCfg = self.jsonCfg.launcher
  self.shootCD = launchCfg.burstCd or 0
  self.shootCount = launchCfg.burstNum or 1
  self.shootIndex = 0
  self.weaponPlayerYaw = launchCfg.weaponPlayerYaw or World.cfg.weaponPlayerYaw
  self.fireRate = launchCfg.fireRate
  self.fireInterval = (launchCfg.burstNum - 1) * self.shootCD + self.fireRate
  self.isFullAuto = launchCfg.fullAuto
  self.isMultiShoot = self.shootCount > 1
  self.weaponSpread = WeaponSpread.new(self)
  self.renderTickListener = Lib.subscribeEvent(Event.EVENT_RENDER_TICK, function(frameTime)
    self:onRenderUpdate(frameTime)
  end)
  self.logicTimer = World.LightTimer("fire behavior", 1, function()
    self:onLogicUpdate()
    return true
  end)
end

function Weapon:initAction(isClient)
  local action = self.jsonCfg.launcher.action
  if not action then
    return
  end
  self.owner:setActionMapping("idle", action.idle)
  self.owner:setActionMapping("run", action.run)
  if not isClient then
    self.owner:sendPacket({
      pid = "initPlayerAction",
      idle = action.idle,
      run = action.run
    })
  end
end

function Weapon:clearAction()
  self.owner:setActionMapping("idle", "idle")
  self.owner:setActionMapping("run", "run")
end

function Weapon:release()
  if self.fire then
    self.fire:release()
  end
  if self.logicTimer then
    self.logicTimer()
    self.logicTimer = nil
  end
  if self.renderTickListener then
    self.renderTickListener()
    self.renderTickListener = nil
  end
end

function Weapon:getType()
  return self.cfg.type
end

function Weapon:getCfgID()
  return self.cfg.id
end

function Weapon:getCfg()
  return self.cfg
end

function Weapon:autoFire()
  if self:openFire() then
    self.isAutoFire = true
    return true
  end
end

function Weapon:openFire()
  print("Weapon:openFire()")
  if self.owner:getMainBulletCount() < 1 then
    Me:playSoundByKey("g2055_gun_bulletRunOut")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("weapon.no.bullet"))
    return
  end
  print("======================Weapon:openFire()")
  self.isFire = true
  self:playAction(self.actionCfg.attack[1])
  self.isOpenFireAction = true
  self.isCloseFire = false
  return true
end

function Weapon:closeFire()
  self.isStopFire = true
  self.isFire = false
  self.isAutoFire = false
  if self:isMultiShooting() then
    self.lastShootCount = self.shootCount - self.shootIndex
  end
  self:playAction("idle")
  self.isOpenFireAction = false
  self.owner:refreshUpperAction()
  self.isCloseFire = true
end

function Weapon:doShake()
  local bulletCfg = self.jsonCfg.bullet
  local fireInterval = bulletCfg.recoilInterval
  local curTime = socket.gettime()
  if curTime >= self.lastShakeTime + fireInterval then
    self.weaponSpread:fireRecoil()
    self.lastShakeTime = curTime
  end
end

function Weapon:isMultiShooting()
  if self.isMultiShoot then
    return self.shootIndex < self.shootCount and self.shootIndex > 0
  end
end

function Weapon:tryMultiShooting(isMultiShooting, bulletCount)
  local curTime = socket.gettime()
  local passTime = curTime - self.lastFireTime
  local hurtCount = 0
  if isMultiShooting then
    if passTime >= self.shootCD then
      if passTime <= (self.shootCount - self.shootIndex) * self.shootCD then
        hurtCount = math.floor(passTime / self.shootCD)
        hurtCount = math.min(hurtCount, bulletCount)
        self.lastFireTime = self.lastFireTime + hurtCount * self.shootCD
      elseif self.lastShootCount then
        hurtCount = self.lastShootCount
        hurtCount = math.min(hurtCount, bulletCount)
        self.lastFireTime = self.lastFireTime + hurtCount * self.shootCD
        self.lastShootCount = nil
      else
        hurtCount = math.floor((passTime - self.fireRate) / self.shootCD) + 1
        hurtCount = math.min(hurtCount, bulletCount)
        self.lastFireTime = self.lastFireTime + (hurtCount - 1) * self.shootCD + self.fireRate
      end
    end
  elseif passTime > self.fireRate then
    if self.isStopFire then
      hurtCount = 1
      self.lastFireTime = curTime
      self.isStopFire = false
    else
      hurtCount = math.floor((passTime - self.fireRate) / self.shootCD) + 1
      hurtCount = math.min(hurtCount, bulletCount)
      self.lastFireTime = self.lastFireTime + (hurtCount - 1) * self.shootCD + self.fireRate
    end
  end
  if 0 < hurtCount then
    self.shootIndex = (self.shootIndex + hurtCount) % self.shootCount
    self:shootOne(hurtCount)
  end
end

function Weapon:tryFire(bulletCount)
  local curTime = socket.gettime()
  local passTime = curTime - self.lastFireTime
  local hurtCount = 0
  if passTime > self.fireRate then
    if self.isStopFire then
      hurtCount = 1
      self.lastFireTime = curTime
      self.isStopFire = false
    else
      hurtCount = math.floor(passTime / self.fireRate)
      hurtCount = math.min(hurtCount, bulletCount)
      self.lastFireTime = self.lastFireTime + hurtCount * self.fireRate
    end
  end
  if 0 < hurtCount then
    self.shootIndex = (self.shootIndex + hurtCount) % self.shootCount
    self:shootOne(hurtCount)
  end
end

function Weapon:onLogicUpdate()
  local bulletCount = self.owner:getMainBulletCount()
  if 0 < bulletCount then
    if not Blockman.instance:control().enable then
      if not self.isCloseFire then
        self:closeFire()
      end
      return
    end
    if self:isMultiShooting() then
      self:tryMultiShooting(true, bulletCount)
      self:doShake()
    elseif self.isFire then
      if self.isMultiShoot then
        self.lastShootCount = nil
        self:tryMultiShooting(false, bulletCount)
      else
        self:tryFire(bulletCount)
      end
      self:doShake()
      if not self.isAutoFire and not self.isFullAuto then
        self.isFire = false
      end
    end
  elseif self.isOpenFireAction then
    self:playAction("idle")
    self.isOpenFireAction = false
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("weapon.no.bullet"))
  end
end

function Weapon:onRenderUpdate(timeDelta)
  self.weaponSpread:onUpdate(timeDelta)
end

function Weapon:shootOne(hurtCount)
  self.isHitHead = false
  self.owner:cutBullet(hurtCount)
  if self.owner:getMainBulletCount() < 1 then
    Me:playSoundByKey("g2055_gun_bulletRunOut")
  end
  if self.jsonCfg.launcher.pellets == 1 then
    local spread = self.weaponSpread:getSpread()
    self:shootOnePellet(spread, nil, nil, hurtCount)
  else
    local pelletSpreadArray = self.jsonCfg.launcher.pelletSpreadArray
    if pelletSpreadArray then
      for i = 1, self.jsonCfg.launcher.pellets do
        local spread = pelletSpreadArray[i]
        self:shootOnePellet(nil, spread[1], spread[2], hurtCount)
      end
    else
      local spread = self.jsonCfg.launcher.pelletSpread
      for i = 1, self.jsonCfg.launcher.pellets do
        self:shootOnePellet(spread, nil, nil, hurtCount)
      end
    end
  end
  if self.jsonCfg.bullet.bornSound then
    self:playSound(self.jsonCfg.bullet.bornSound)
  end
  if self.lastShootCount then
    self.lastShootCount = self.lastShootCount - 1
    if 1 > self.lastShootCount then
      self.lastShootCount = nil
    end
  end
  Lib.emitEvent(Event.EVENT_RETICLE_SCALING, self.isHitHead)
end

function Weapon:playSound(key)
  local sid = 0
  if key then
    sid = self.owner:playSound(SoundConfig:getSound(key))
  end
end

function Weapon:shootOnePellet(spread, pitch, yaw, hurtCount)
  local curCamera = Camera.getActiveCamera()
  local origin = curCamera:getPosition()
  local length = Define.WeaponShotRange
  local offsetPitch = pitch
  local offsetYaw = yaw
  if spread then
    local offsetAngleRatio = 1000
    local offsetAngle = spread * offsetAngleRatio or 0
    offsetAngle = math.ceil(offsetAngle)
    offsetPitch = math.random(-offsetAngle, offsetAngle) / offsetAngleRatio
    offsetYaw = math.random(-offsetAngle, offsetAngle) / offsetAngleRatio
  end
  local direction = curCamera:getDirection()
  local dir = direction
  direction = Quaternion.rotateAxis({
    x = 0,
    y = -1,
    z = 0
  }, offsetYaw) * Quaternion.rotateAxis(dir:cross(Lib.v3(0, 1, 0)), offsetPitch) * dir
  self:startRayCast(origin, direction, length, hurtCount)
end

function Weapon:startRayCast(origin, direction, curLength, hurtCount)
  local offsetPos = self.jsonCfg.bullet.offset
  local clonePosition = Vector3.new(offsetPos[1], offsetPos[2], offsetPos[3])
  local rotation = Vector3.new(-self.owner:getRotationPitch(), -self.owner:getRotationYaw(), -self.owner:getRotationRoll())
  Lib.rotate(clonePosition, rotation)
  local weaponPos = self.owner:getPosition() + clonePosition
  local offPos = Vector3.new(0.2, 1, -0.5)
  Lib.rotate(offPos, rotation)
  local facePos = self.owner:getPosition() + offPos
  local endPos
  local hitObj, hitBoxType = RayTestHelper:startRayCast(facePos, origin, direction, curLength)
  if hitObj and hitBoxType then
    if hitBoxType == Define.HIT_BOX_TYPE.HEAD then
      self.isHitHead = true
    end
    local objID = hitObj.target.parentObjID
    if objID ~= Me.objID then
      local info = {}
      info.damagePos = hitObj.collidePos
      info.attackObjID = self.owner.objID
      info.weaponId = self.id
      info.attackCount = hurtCount
      info.hurtObjID = objID
      info.hurtType = hitBoxType
      info.sourcePos = self.owner:getPosition()
      local hurtEntity = World.CurWorld:getEntity(objID)
      info.targetPos = hurtEntity:getPosition()
      self.owner:sendPacket({
        pid = "BulletDoDamage",
        damageInfo = info
      })
      endPos = hitObj.collidePos
    end
  end
  local hitEffectData, bulletEffectData
  if hitObj then
    endPos = hitObj.collidePos
    local hitEffect = self.jsonCfg.bullet.hitEffect
    if hitEffect then
      local dis = Lib.getPosDistance(endPos, self.owner:getPosition())
      if 2 < dis then
        hitEffectData = {
          objID = self.owner.objID,
          effect = hitEffect.effect,
          pos = endPos,
          time = hitEffect.time
        }
      end
    end
  end
  if not endPos then
    local d = Lib.copy(direction)
    d:normalize()
    endPos = weaponPos + d * 10
  end
  local rotation = Vector3.new(self.owner:getRotationPitch(), -self.owner:getRotationYaw(), -self.owner:getRotationRoll())
  WeaponEffectHelper:showBulletEffect(self.jsonCfg.bullet.effectName, self.jsonCfg.bullet, weaponPos, endPos, rotation)
  bulletEffectData = {
    objID = self.owner.objID,
    weaponId = self.id,
    beginPos = weaponPos,
    endPos = endPos,
    rotation = rotation
  }
  self.owner:sendPacket({
    pid = "BulletEffect",
    hitEffectData = hitEffectData,
    bulletEffectData = bulletEffectData
  })
  if hitEffectData then
    WeaponEffectHelper:showHitEffect(hitEffectData.effect, hitEffectData.pos, hitEffectData.time)
  end
end

function Weapon:getLauncher()
  return self.jsonCfg.launcher
end

function Weapon:getIsAutoAim()
  if self.jsonCfg.launcher.autoAim == nil then
    return World.cfg.autoAim
  else
    return self.jsonCfg.launcher.autoAim
  end
end

function Weapon:getIsAutoFire()
  if self.jsonCfg.launcher.autoFire == nil then
    return World.cfg.autoFire
  else
    return self.jsonCfg.launcher.autoFire
  end
end

function Weapon:isMelee()
  return false
end

function Weapon:attack()
end

function Weapon:playAction(actionName, time)
  print("Weapon:playAction", actionName)
  time = time or -1
  self.owner:sendPacket({
    pid = "playerAction",
    actionName = actionName,
    time = time
  })
  self.owner:updateUpperAction1(actionName, time, true, 0, true)
end

function Weapon:getWeaponPlayerYaw()
  return self.weaponPlayerYaw
end

function Weapon:updateCamera()
  local CameraManager = T(Lib, "CameraManager")
  CameraManager:weaponView(self.jsonCfg.launcher.camera)
end

function Weapon:checkAttackHurt()
end

function Weapon:getMoveSpeed()
  return self.jsonCfg.launcher.moveSpeed, self.jsonCfg.launcher.moveAcc
end

return Weapon

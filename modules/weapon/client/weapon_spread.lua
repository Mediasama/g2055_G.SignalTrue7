local WeaponSpread = Lib.class("WeaponSpread")

function WeaponSpread:ctor(weapon)
  self.weapon = weapon
  self.bulletCfg = weapon.jsonCfg.bullet
  self.launcherCfg = weapon.jsonCfg.launcher
  self.fireIndex = 0
  self.recoilCount = 0
  self.recoilPitch = 0
  self.recoilYaw = 0
  self.endPitchTime = 0
  self.endYawTime = 0
  self._lastRecoilYaw = 0
  self._lastRecoilPitch = 0
  self.timeLine = 0
  self.backPitch = 0
  self.backYaw = 0
  self.interval = self.bulletCfg.recoilInterval
end

function WeaponSpread:onUpdate(timeDelta)
  self.timeLine = self.timeLine + timeDelta
  self:updateRecoilAndSpread(timeDelta)
  self.testShootDt = self.testShootDt and self.testShootDt + timeDelta or timeDelta
end

function WeaponSpread:getSpread()
  local conf = self.bulletCfg
  local index
  for i = 1, #conf.spreadXY do
    if self.backPitch < conf.spreadXY[i] then
      index = i
    end
  end
  local spread = conf.spreadValues[index]
  return spread
end

function WeaponSpread:addTestBullet()
  if self.testBulletIndex and self.testBulletIndex < 11 then
    local oldPitch = self.weapon.owner:getRotationPitch()
    local oldYaw = self.weapon.owner:getRotationYaw()
    self:fireRecoil()
    self.testBulletIndex = self.testBulletIndex + 1
  end
end

function WeaponSpread:onTestBullet()
  self.testBulletIndex = 1
  self.endPitchTime = 0
  self.endYawTime = 0
  self._lastRecoilYaw = 0
  self._lastRecoilPitch = 0
  self.lastFirePitch = 0
  self.lastFireYaw = 0
  self.recoilCount = 0
end

local function Sign(num)
  if num == 0 then
    return 0
  elseif 0 < num then
    return -1
  else
    return 1
  end
end

function WeaponSpread:calcTime(s0, s, bv0, isBalance, t1)
  local t
  if not isBalance then
    t = (s0 + s) / bv0
  else
    t = self.interval - t1 + s0 / bv0
  end
  return t
end

function WeaponSpread:calcShift(s, bv0, isBalance, t1, t)
  local v0 = s / t1
  if t <= t1 then
    return v0 * t
  end
  local s2
  if not isBalance then
    s2 = bv0 * (t - t1)
  elseif t > self.interval then
    s2 = bv0 * (t - self.interval) + s
  else
    local v1 = s / (self.interval - t1)
    s2 = v1 * (t - t1)
  end
  return s - s2, s2
end

function WeaponSpread:resetBackRecoil()
  self.backPitch = 0
  self.backYaw = 0
end

function WeaponSpread:fireRecoil()
  self.fireIndex = self.fireIndex + 1
  local conf = self.bulletCfg
  self.backMaxPitch = self.backPitch
  self.backMaxYaw = self.backYaw
  self.recoilPitchS = math.random(math.ceil(conf.recoilPitchS[1] * 10000), math.ceil(conf.recoilPitchS[2] * 10000)) / 10000
  self.pitchT1 = conf.recoilT
  self.pitchBalance = self.backPitch + self.recoilPitchS > conf.recoilPitchSMax
  self.pitchBv0 = self.recoilPitchS / conf.recoilBackT
  if self.pitchBalance then
    self.recoilPitchS = math.random(math.ceil(conf.recoilPitchBalanceS[1] * 10000), math.ceil(conf.recoilPitchBalanceS[2] * 10000)) / 10000
    self.pitchT1 = conf.recoilPitchBalanceT
  end
  self.recoilYawS = math.random(math.ceil(conf.recoilYawS[1] * 10000), math.ceil(conf.recoilYawS[2] * 10000)) / 10000
  self.yawT1 = conf.recoilT
  self.yawBalance = self.backYaw + self.recoilYawS > conf.recoilYawSMax
  self.yawBv0 = self.recoilYawS / conf.recoilBackT
  if self.yawBalance then
    self.recoilYawS = math.random(math.ceil(conf.recoilYawBalanceS[1] * 10000), math.ceil(conf.recoilYawBalanceS[2] * 10000)) / 10000
    self.yawT1 = conf.recoilYawBalanceT
  end
  local t1 = self:calcTime(self.backPitch, self.recoilPitchS, self.pitchBv0, self.pitchBalance, self.pitchT1)
  self.endPitchTime = self.timeLine + self.pitchT1 + t1
  local t2 = self:calcTime(self.backYaw, self.recoilYawS, self.yawBv0, self.yawBalance, self.yawT1)
  self.endYawTime = self.timeLine + self.yawT1 + t2
  self.recoilPitchFlip = false
  if self.recoilPitchS >= conf.recoilPitchSMax then
    local a = math.random(0, 3)
    if 2 <= a then
      self.recoilPitchFlip = true
    end
  end
  self.recoilYawFlip = false
  if self.recoilYawS >= conf.recoilYawSMax then
    local a = math.random(0, 3)
    if 2 <= a then
      self.recoilYawFlip = true
    end
  end
  self.lastFireTime = self.timeLine
  self._lastRecoilPitch = 0
  self._lastRecoilYaw = 0
  if self.testBulletIndex and self.testBulletIndex < 11 then
    local oldPitch = self.weapon.owner:getRotationPitch()
    local oldYaw = self.weapon.owner:getRotationYaw()
    local curYaw = oldYaw + self.recoilYaw - self._lastRecoilYaw
    local curPitch = oldPitch - self.recoilPitch + self._lastRecoilPitch
    local offsetAngleRatio = 1000
    local offsetAngle = math.ceil(self:getSpread() * offsetAngleRatio)
    local offsetPitch = math.random(-offsetAngle, offsetAngle) / offsetAngleRatio
    local offsetYaw = math.random(-offsetAngle, offsetAngle) / offsetAngleRatio
    Lib.emitEvent(Event.EVENT_HOLE, self.testBulletIndex, curPitch + offsetPitch, curYaw + offsetYaw, self.bulletCfg)
  end
end

function WeaponSpread:updateRecoilAndSpread(timeDelta)
  if self.endPitchTime == 0 and self.endYawTime == 0 then
    return
  end
  local conf = self.bulletCfg
  if self.timeLine <= self.endPitchTime then
    self.recoilPitch = self:calcShift(self.recoilPitchS, self.pitchBv0, self.pitchBalance, self.pitchT1, self.timeLine - self.lastFireTime)
    if self.recoilPitchFlip then
      self.recoilPitch = -self.recoilPitch
    end
  else
    self.recoilPitch = self._lastRecoilPitch
  end
  if self.timeLine < self.endYawTime then
    self.recoilYaw = self:calcShift(self.recoilYawS, self.yawBv0, self.yawBalance, self.yawT1, self.timeLine - self.lastFireTime)
    if self.recoilYawFlip then
      self.recoilYaw = -self.recoilYaw
    end
  else
    self.recoilYaw = self._lastRecoilYaw
  end
  local oldPitch = self.weapon.owner:getRotationPitch()
  local oldYaw = self.weapon.owner:getRotationYaw()
  if self.recoilPitch - self._lastRecoilPitch == 0 and self.recoilYaw - self._lastRecoilYaw == 0 then
    return
  end
  self.backPitch = self.backPitch + self.recoilPitch - self._lastRecoilPitch
  self.backYaw = self.backYaw + self.recoilYaw - self._lastRecoilYaw
  local curYaw = oldYaw + self.recoilYaw - self._lastRecoilYaw
  local curPitch = oldPitch - self.recoilPitch + self._lastRecoilPitch
  self.weapon.owner:changeCameraView(nil, curYaw, curPitch, nil, nil)
  self._lastRecoilYaw = self.recoilYaw
  self._lastRecoilPitch = self.recoilPitch
end

return WeaponSpread

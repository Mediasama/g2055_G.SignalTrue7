local BlinkTime = 1
local BlinkCount = 1
local HurtFrameCount = 40
local LuaTimer = T(Lib, "LuaTimer")

function M:onOpen(params)
  self:initUI()
  self:initUIControl()
end

function M:initUI()
  self.hurtImage:setVisible(false)
  self.dirImage:setVisible(true)
  self.dirImage:setAlpha(0)
end

function M:initUIControl()
  Lib.subscribeEvent(Event.EVENT_ON_HURT, function(pos)
    self:blinking()
    self:showHurtDir(pos)
  end)
end

function M:blinking()
  if self.blinkingTimer then
    self.blinkingTimer()
    self.blinkingTimer = nil
  end
  local count = 0
  self.blinkingTimer = Me:timer(BlinkTime, function()
    count = count + 1
    local b = self.hurtImage:isVisible()
    self.hurtImage:setVisible(not b)
    if count < BlinkCount * 2 then
      return true
    end
    self.hurtImage:setVisible(false)
  end)
end

local rotationV3 = {
  x = 0,
  y = 0,
  z = 1
}

local function rotationToQuaternion(v3, rotation)
  local halfRotation = 0.5 * rotation
  local halfSin = math.sin(halfRotation)
  return {
    w = math.cos(halfRotation),
    x = v3.x * halfSin,
    y = v3.y * halfSin,
    z = v3.z * halfSin
  }
end

function M:showHurtDir(pos)
  local curCamera = Camera.getActiveCamera()
  local dir1 = curCamera:getDirection()
  local dir2 = pos - Me:getPosition()
  local qu = Quaternion.fromVectorRotation(dir1, dir2)
  local pitch, yaw, roll = qu:toEulerAngle()
  print("pitch, yaw, roll", yaw)
  local degree = 0
  if yaw < 0 then
    degree = -yaw
  elseif 0 < yaw then
    degree = 360 - yaw
  end
  local leftQ = rotationToQuaternion(rotationV3, math.rad(degree))
  self.dirImage:setProperty("Rotation", "w:" .. leftQ.w .. " x:" .. leftQ.x .. " y:" .. leftQ.y .. " z:" .. leftQ.z)
  if self.reticleHitTimer then
    LuaTimer:cancel(self.reticleHitTimer)
  end
  self.alpha = 1
  self.dirImage:setAlpha(self.alpha)
  self.reticleHitTimer = LuaTimer:scheduleTimer(function()
    self.alpha = math.max(0, self.alpha - 1 / HurtFrameCount)
    self.dirImage:setAlpha(self.alpha)
    if self.alpha <= 0 then
      LuaTimer:cancel(self.reticleHitTimer)
      self.reticleHitTimer = nil
    end
  end, 50)
end

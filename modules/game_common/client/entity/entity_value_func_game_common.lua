local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity:resetBodyYaw(value)
  local yaw = value - (self.resetOffsetYaw or 0)
  self:setBodyYaw(yaw)
  self.resetOffsetYaw = 0
end

function Entity:setBodyYawEx(value)
  local offset = 0
  if self.weapon then
    offset = self.weapon:getWeaponPlayerYaw()
  end
  self.resetOffsetYaw = offset
  local yaw = value + offset
  self:setBodyYaw(yaw)
end

function Entity:updateBodyYaw()
  local bm = Blockman:Instance()
  local yaw = bm:getViewerYaw()
  self:setBodyYawEx(yaw)
end

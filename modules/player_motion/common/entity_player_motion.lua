local ValueDef = T(Entity, "ValueDef")
ValueDef.player_motion_property = {
  false,
  false,
  true,
  true,
  {},
  false
}
ValueDef.player_motion_paid = {
  false,
  false,
  true,
  false,
  {},
  true
}
local EntityPlayerMotion = Entity

function EntityPlayerMotion:pam_getProperty()
  return self:getValue("player_motion_property") or {}
end

function EntityPlayerMotion:pam_setProperty(value)
  self:setValue("player_motion_property", value)
end

function EntityPlayerMotion:pam_getMotionID()
  local property = self:pam_getProperty()
  return property.motionId or 0
end

function EntityPlayerMotion:pam_setMotionID(id)
  local property = self:pam_getProperty()
  property.motionId = id
  self:pam_setProperty(property)
end

function EntityPlayerMotion:getPlayerMotionPaid()
  return self:getValue("player_motion_paid") or {}
end

function EntityPlayerMotion:setPlayerMotionPaid(value)
  self:setValue("player_motion_paid", value)
end

function EntityPlayerMotion:addPlayerMotionPaid(id)
  local property = self:getPlayerMotionPaid()
  property[id] = 1
  self:setPlayerMotionPaid(property)
end

function EntityPlayerMotion:checkPlayerMotionPaid(id)
  local property = self:getPlayerMotionPaid()
  return property[id] == 1
end

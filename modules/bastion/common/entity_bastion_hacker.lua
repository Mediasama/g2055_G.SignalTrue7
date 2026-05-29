local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_hacker_property = {
  false,
  false,
  true,
  true,
  {},
  false
}
local EntityBastion = Entity

function EntityBastion:bhp_getProperty()
  return self:getValue("bastion_hacker_property") or {}
end

function EntityBastion:bhp_setProperty(property)
  self:setValue("bastion_hacker_property", property)
end

function EntityBastion:bhp_getHackObjID()
  local property = self:bhp_getProperty()
  return property.hackObjID or 0
end

function EntityBastion:bhp_setHackObjID(objID)
  local property = self:bhp_getProperty()
  property.hackObjID = objID
  self:bhp_setProperty(property)
  if 0 < objID then
    self:addBuff("myplugin/player_posture_pick_lock")
  else
    self:removeTypeBuff("fullName", "myplugin/player_posture_pick_lock")
  end
end

function EntityBastion:bhp_getBastionPosition()
  local property = self:bhp_getProperty()
  return property.bastionPosition or Vector3.new(0, 0, 0)
end

function EntityBastion:bhp_setBastionPosition(pos)
  local property = self:bhp_getProperty()
  property.bastionPosition = pos
  self:bhp_setProperty(property)
end

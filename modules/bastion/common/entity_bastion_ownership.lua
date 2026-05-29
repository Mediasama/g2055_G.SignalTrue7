local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_ownership = {
  false,
  false,
  true,
  true,
  {},
  false
}
local EntityBastion = Entity

function EntityBastion:getBastionOwnership()
  return self:getValue("bastion_ownership")
end

function EntityBastion:setBastionOwnership(value)
  self:setValue("bastion_ownership", value)
end

function EntityBastion:getBastionUid()
  local ownership = self:getBastionOwnership() or {}
  return ownership.bastionUid
end

function EntityBastion:setBastionUid(uid)
  local ownership = self:getBastionOwnership() or {}
  ownership.bastionUid = uid
  self:setBastionOwnership(ownership)
end

function EntityBastion:getBastionOwnerId()
  local ownership = self:getBastionOwnership() or {}
  return ownership.ownerId
end

function EntityBastion:setBastionOwnerId(id)
  local ownership = self:getBastionOwnership() or {}
  ownership.ownerId = id
  self:setBastionOwnership(ownership)
end

function EntityBastion:getBastionFacilityType()
  local ownership = self:getBastionOwnership() or {}
  return ownership.facilityType or Define.Bastion.Facility.Type.None
end

function EntityBastion:setBastionFacilityType(facilityType)
  local ownership = self:getBastionOwnership() or {}
  ownership.facilityType = facilityType
  self:setBastionOwnership(ownership)
end

function EntityBastion:getBastionDefenseType()
  local ownership = self:getBastionOwnership() or {}
  return ownership.defenseType or Define.Bastion.Defense.Type.None
end

function EntityBastion:setBastionDefenseType(defenseType)
  local ownership = self:getBastionOwnership() or {}
  ownership.defenseType = defenseType
  self:setBastionOwnership(ownership)
end

function EntityBastion:getFacilityCfgID()
  local ownership = self:getBastionOwnership() or {}
  return ownership.facilityCfgID
end

function EntityBastion:setFacilityCfgID(facilityCfgID)
  local ownership = self:getBastionOwnership() or {}
  ownership.facilityCfgID = facilityCfgID
  self:setBastionOwnership(ownership)
end

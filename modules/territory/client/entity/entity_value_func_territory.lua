local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:inComeProcessInfo()
  self:updateInComeProcessInfo()
end

function Entity.ValueFunc:territoryOwner()
  self:updateTerritoryOwnerEntityEffect()
end

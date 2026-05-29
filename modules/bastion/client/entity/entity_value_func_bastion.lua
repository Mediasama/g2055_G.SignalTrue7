local EntityBastionClient = Entity

function EntityBastionClient.ValueFunc:bastion_ownership(value)
  self:updateBastionFacilityInfo()
  self:updateFacilityEffect()
end

function EntityBastionClient.ValueFunc:bastion_defense_property_copy(value)
  self:updateBastionDefenseInfo()
end

function EntityBastionClient.ValueFunc:bastion_defense_property_runtime(value)
  self:updateBastionDefenseInfo()
end

function EntityBastionClient.ValueFunc:bastion_hacker_property(value)
  self:updateUnlockDoorStatus()
end

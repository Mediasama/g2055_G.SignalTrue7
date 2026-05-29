local EntityNpcDoorClient = Entity
local ValueFunc = T(Entity, "ValueFunc")

function EntityNpcDoorClient.ValueFunc:npc_door_property(value)
  self:ndp_updateProperty()
end

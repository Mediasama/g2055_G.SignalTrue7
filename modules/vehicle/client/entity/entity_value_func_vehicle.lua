local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:hasPassenger(value)
  Lib.emitEvent(Event.EVENT_HAS_PASSENGER, value, self.objID)
end

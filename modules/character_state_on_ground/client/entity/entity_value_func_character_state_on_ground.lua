local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:autoHurtSelf(value)
  Lib.emitEvent(Event.EVENT_UPDATE_AUTO_HURT_SELF, value, self.objID)
end

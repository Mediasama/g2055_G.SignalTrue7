if World.isClient then
  Event.CUBE_NUM_CHANGE = Event.register("CUBE_NUM_CHANGE")
  Event.register("EVENT_RENDER_TICK")
  Event.register("EVENT_SHOW_MONEY")
  local events = require("client.entity.entity_event")
  local oldMoveStatusChange = events.moveStatusChange
  
  function events:moveStatusChange(entityId, newState, oldState)
    oldMoveStatusChange(self, entityId, newState, oldState)
    local entity = World.CurWorld:getObject(entityId)
    if entity and entity:isValid() and entity:cfg().isTrolley then
      Lib.emitEvent(Event.EVENT_VEHICLE_STATUS_CHANGE, entity, newState, oldState)
    end
  end
else
  local events = require("server.entity.entity_event")
  
  function events:entityTouchAll(other)
    Trigger.CheckTriggers(self:cfg(), Define.EntityCollideHandlers.ENTITY_COLLISION_TOUCH, {obj1 = self, other = other})
  end
  
  function events:entityApartAll(other)
    Trigger.CheckTriggers(self:cfg(), Define.EntityCollideHandlers.ENTITY_COLLISION_APART, {obj1 = self, other = other})
  end
end

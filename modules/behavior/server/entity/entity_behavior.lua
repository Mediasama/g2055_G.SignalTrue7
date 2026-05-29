local EntityServer = _ENV.EntityServer
local BehaviorManager = require("common.behavior_manager")

function EntityServer:onConnectCollideEvent()
  self:connect("touch_enter", self, "onCollisionEnter")
  self:connect("touch_leave", self, "onCollisionLeave")
end

function EntityServer:onCollisionEnter(operator, typename)
  if typename ~= "Entity" or not operator.isPlayer then
    return
  end
  Trigger.CheckTriggers(self:cfg(), Define.EntityCollideHandlers.ENTITY_COLLISION_ENTER, {obj1 = self, other = operator})
end

function EntityServer:onCollisionLeave(operator, typename)
  if typename ~= "Entity" or not operator.isPlayer then
    return
  end
  Trigger.CheckTriggers(self:cfg(), Define.EntityCollideHandlers.ENTITY_COLLISION_LEAVE, {obj1 = self, other = operator})
end

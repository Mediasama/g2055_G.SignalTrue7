require("common.entity_behavior")
require("common.event_behavior")
require("common.define_behavior")
require("common.map_behavior")
if World.isClient then
  require("client.player.player_behavior")
  require("client.player.packet_behavior")
  require("client.entity.entity_behavior")
  require("client.entity.entity_value_func_behavior")
  require("client.gate_behavior")
  require("client.gm_behavior")
else
  require("server.player.player_behavior")
  require("server.player.packet_behavior")
  require("server.entity.entity_behavior")
  require("server.gate_behavior")
  require("server.gm_behavior")
end
local BehaviorManager = require("common.behavior_manager")
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local target = context.obj1
  if not target then
    return
  end
  BehaviorManager.Instance():operateUnit(target:getUnitLocator(), target:getUnitLocator(), Define.EntityOperation.Type.Spawn, nil, false)
  target:onConnectCollideEvent()
end

function handlers.ENTITY_LEAVE(context)
  local target = context.obj1
  if not target then
    return
  end
  BehaviorManager.Instance():operateUnit(target:getUnitLocator(), target:getUnitLocator(), Define.EntityOperation.Type.Destroy, nil, false)
end

function handlers.ENTITY_COLLISION_ENTER(context)
  local target = context.obj1
  local operator = context.other
  if not target or not operator then
    return
  end
  if operator.isPlayer then
    operator.lastColContext = context
  end
  BehaviorManager.Instance():operateUnit(target:getUnitLocator(), operator:getUnitLocator(), Define.EntityOperation.Type.EntityEnter, nil, false)
end

function handlers.ENTITY_COLLISION_LEAVE(context)
  local target = context.obj1
  local operator = context.other
  if not target or not operator then
    return
  end
  if operator.isPlayer then
    operator.lastColContext = nil
  end
  BehaviorManager.Instance():operateUnit(target:getUnitLocator(), operator:getUnitLocator(), Define.EntityOperation.Type.EntityLeave, nil, false)
end

function handlers.PLAYER_TELEPORT_MAP(context)
  local player = context.obj1
  if not player then
    return
  end
  local map = player.map
  if not map then
    return
  end
  local cfg = map.cfg
  if not cfg then
    return
  end
  local operationConfig = cfg.operationConfig or {}
  local operationList = operationConfig.teleportMap or {}
  BehaviorManager.Instance():tryOperateUnit(player:getUnitLocator(), player:getUnitLocator(), operationList)
end

function handlers.PLAYER_TELEPORT_POSITION(context)
  local player = context.obj1
  if not player then
    return
  end
  local map = player.map
  if not map then
    return
  end
  local cfg = map.cfg
  if not cfg then
    return
  end
  local operationConfig = cfg.operationConfig or {}
  local operationList = operationConfig.teleportPosition or {}
  BehaviorManager.Instance():tryOperateUnit(player:getUnitLocator(), player:getUnitLocator(), operationList)
end

function handlers.ENTITY_RIDE_ON(context)
  local rider = context.obj2
  local mount = context.obj1
  if not rider or not mount then
    return
  end
  BehaviorManager.Instance():operateUnit(mount:getUnitLocator(), rider:getUnitLocator(), Define.EntityOperation.Type.RideOn, nil, false)
end

function handlers.ENTITY_RIDE_OFF(context)
  local rider = context.obj2
  local mount = context.obj1
  if not rider or not mount then
    return
  end
  BehaviorManager.Instance():operateUnit(mount:getUnitLocator(), rider:getUnitLocator(), Define.EntityOperation.Type.RideOff, nil, false)
end

function handlers.OnPlayerLogin(player)
  player:doSetProp("newTouchCollisionMask", Define.PLAYER_TOUCH_GROUP_SERVER)
end

function handlers.onPlayerLogout(player)
  if player and player:isValid() and player.lastColContext then
    handlers.ENTITY_COLLISION_LEAVE(player.lastColContext)
    player.lastColContext = nil
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

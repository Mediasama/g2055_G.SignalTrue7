require("common.entity_vehicle")
require("common.event_vehicle")
require("common.config.vehicle_base_config")
require("common.define_vehicle")
require("common.vehicle_helper")
require("common.player_vehicle_common")
if World.isClient then
  require("client.player.player_vehicle")
  require("client.player.packet_vehicle")
  require("client.entity.entity_vehicle")
  require("client.entity.entity_value_func_vehicle")
  require("client.gate_vehicle")
  require("client.gm_vehicle")
else
  require("server.player.player_vehicle")
  require("server.player.packet_vehicle")
  require("server.entity.entity_vehicle")
  require("server.trigger_handlers")
  require("server.gate_vehicle")
  require("server.gm_vehicle")
  require("server.vehicle_manager")
end
local VehicleManager = T(Lib, "VehicleManager")
local handlers = {}

function handlers.onPlayerLogout(player)
  if player then
    VehicleManager:playerCancelUnlocking(player.platformUserId)
  end
end

function handlers.ENTITY_ENTER(context)
  local target = context.obj1
  if not target then
    return
  end
  if target.isPlayer or target:cfg().isTrolley then
    target:onConnectVehicleCollideEvent()
  end
end

function handlers.ENTITY_STATUS_CHANGE(context)
  local entity = context.obj1
  local newState = context.newState
  if not (entity and entity:isValid()) or not newState then
    return
  end
  local cfg = entity:cfg()
  if not cfg.isTrolley then
    return
  end
  entity:addVehicleBuffByState(newState)
end

function handlers.ENTITY_LEAVE(context)
  local target = context.obj1
  if not target or not target:isValid() then
    return
  end
  local cfg = target:cfg()
  if cfg.isTrolley then
    target:cancelDestroyTimer()
    VehicleManager:carCancelUnlocking(target.objID)
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

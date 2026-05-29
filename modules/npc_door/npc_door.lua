require("common.entity_npc_door")
require("common.event_npc_door")
require("common.config.npc_doors_config")
require("common.define_npc_door")
if World.isClient then
  require("client.player.player_npc_door")
  require("client.player.packet_npc_door")
  require("client.entity.entity_npc_door")
  require("client.entity.entity_value_func_npc_door")
  require("client.gate_npc_door")
  require("client.gm_npc_door")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:ndp_updateProperty()
    end
  end)
else
  require("server.player.player_npc_door")
  require("server.player.packet_npc_door")
  require("server.entity.entity_npc_door")
  require("server.gate_npc_door")
  require("server.gm_npc_door")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local NPCDoorManager = require("server.npc_door_manager")
  NPCDoorManager.Instance():loadDoors()
end

function handlers.PLAYER_DIE_TRIGGER_EVENT(context)
  local player = context.player
  local NPCDoorManager = require("server.npc_door_manager")
  NPCDoorManager.Instance():onPlayerDie(player.platformUserId)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

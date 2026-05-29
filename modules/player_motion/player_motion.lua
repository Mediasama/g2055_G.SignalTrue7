require("common.entity_player_motion")
require("common.event_player_motion")
require("common.define_player_motion")
require("common.config.player_motion_config")
if World.isClient then
  require("client.player.player_player_motion")
  require("client.player.packet_player_motion")
  require("client.entity.entity_player_motion")
  require("client.entity.entity_value_func_player_motion")
  require("client.gate_player_motion")
  require("client.gm_player_motion")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:pam_updateMotion()
    end
  end)
else
  require("server.player.player_player_motion")
  require("server.player.packet_player_motion")
  require("server.entity.entity_player_motion")
  require("server.gate_player_motion")
  require("server.gm_player_motion")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

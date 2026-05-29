require("common.entity_character_state_on_ground")
require("common.event_character_state_on_ground")
require("common.define_character_state_on_ground")
if World.isClient then
  require("client.player.player_character_state_on_ground")
  require("client.player.packet_character_state_on_ground")
  require("client.entity.entity_character_state_on_ground")
  require("client.entity.entity_value_func_character_state_on_ground")
  require("client.gate_character_state_on_ground")
  require("client.gm_character_state_on_ground")
else
  require("server.player.player_character_state_on_ground")
  require("server.player.player_die_sub_state_manager")
  require("server.player.packet_character_state_on_ground")
  require("server.entity.entity_character_state_on_ground")
  require("server.gate_character_state_on_ground")
  require("server.gm_character_state_on_ground")
end
local handlers = {}

function handlers.onPlayerLogout(player)
  player:dieSubStatePlayerLogout()
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

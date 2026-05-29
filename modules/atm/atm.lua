require("common.entity_atm")
require("common.event_atm")
require("common.config.atm_config")
require("common.define_atm")
if World.isClient then
  require("client.player.player_atm")
  require("client.player.packet_atm")
  require("client.entity.entity_atm")
  require("client.entity.entity_value_func_atm")
  require("client.gate_atm")
  require("client.gm_atm")
else
  require("server.player.player_atm")
  require("server.player.packet_atm")
  require("server.entity.entity_atm")
  require("server.gate_atm")
  require("server.gm_atm")
  require("server.atm_manager")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local ATMManager = T(Lib, "ATMManager")
  ATMManager:init()
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

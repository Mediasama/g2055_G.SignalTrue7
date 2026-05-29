require("common.entity_tattoo")
require("common.event_tattoo")
require("common.config.tattoo_config")
require("common.define_tattoo")
if World.isClient then
  require("client.player.player_tattoo")
  require("client.player.packet_tattoo")
  require("client.entity.entity_tattoo")
  require("client.entity.entity_value_func_tattoo")
  require("client.gate_tattoo")
  require("client.gm_tattoo")
else
  require("server.player.player_tattoo")
  require("server.player.packet_tattoo")
  require("server.entity.entity_tattoo")
  require("server.gate_tattoo")
  require("server.gm_tattoo")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local m_TattooManager = require("server.tattoo_manager")
  m_TattooManager:getInstance():createTattooEntity()
end

function handlers.onPlayerLogout(player)
  local m_TattooManager = require("server.tattoo_manager")
  m_TattooManager:getInstance():onPlayerLogout(player)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

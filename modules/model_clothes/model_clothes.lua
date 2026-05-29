require("common.entity_model_clothes")
require("common.event_model_clothes")
require("common.define_model_clothes")
require("common.config.clothes_config")
if World.isClient then
  require("client.player.player_model_clothes")
  require("client.player.packet_model_clothes")
  require("client.entity.entity_model_clothes")
  require("client.entity.entity_value_func_model_clothes")
  require("client.gate_model_clothes")
  require("client.gm_model_clothes")
else
  require("server.player.player_model_clothes")
  require("server.player.packet_model_clothes")
  require("server.entity.entity_model_clothes")
  require("server.gate_model_clothes")
  require("server.gm_model_clothes")
end
local handlers = {}

function handlers.OnPlayerLogin(player)
  player:initModelClothes()
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

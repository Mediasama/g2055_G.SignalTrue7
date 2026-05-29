require("common.entity_item")
require("common.event_item")
require("common.define_item")
require("common.config.goods_base_config")
if World.isClient then
  require("client.player.player_item")
  require("client.player.packet_item")
  require("client.entity.entity_item")
  require("client.entity.entity_value_func_item")
  require("client.gate_item")
  require("client.gm_item")
else
  require("server.player.player_item")
  require("server.player.packet_item")
  require("server.entity.entity_item")
  require("server.gate_item")
  require("server.gm_item")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

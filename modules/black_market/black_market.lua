require("common.entity_black_market")
require("common.event_black_market")
require("common.config.black_market_goods_config")
require("common.define_black_market")
if World.isClient then
  require("client.player.player_black_market")
  require("client.player.packet_black_market")
  require("client.entity.entity_black_market")
  require("client.entity.entity_value_func_black_market")
  require("client.gate_black_market")
  require("client.gm_black_market")
else
  require("server.player.player_black_market")
  require("server.player.packet_black_market")
  require("server.entity.entity_black_market")
  require("server.gate_black_market")
  require("server.gm_black_market")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

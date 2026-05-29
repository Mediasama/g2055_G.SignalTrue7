require("common.define_goods_shelf")
require("common.entity_goods_shelf")
require("common.event_goods_shelf")
require("common.config.goods_shelf_config")
if World.isClient then
  require("client.player.player_goods_shelf")
  require("client.player.packet_goods_shelf")
  require("client.entity.entity_goods_shelf")
  require("client.entity.entity_value_func_goods_shelf")
  require("client.gate_goods_shelf")
  require("client.gm_goods_shelf")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:updateGoodsShelfProperty()
    end
  end)
else
  require("server.player.player_goods_shelf")
  require("server.player.packet_goods_shelf")
  require("server.entity.entity_goods_shelf")
  require("server.gate_goods_shelf")
  require("server.gm_goods_shelf")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local GoodsShelfManager = require("server.goods_shelf_manager")
  GoodsShelfManager.Instance():loadShelves()
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

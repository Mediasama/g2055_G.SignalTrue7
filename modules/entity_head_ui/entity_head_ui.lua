require("common.entity_entity_head_ui")
require("common.event_entity_head_ui")
require("common.define_entity_head_ui")
if World.isClient then
  require("client.player.player_entity_head_ui")
  require("client.player.packet_entity_head_ui")
  require("client.entity.entity_entity_head_ui")
  require("client.entity.entity_value_func_entity_head_ui")
  require("client.gate_entity_head_ui")
  require("client.gm_entity_head_ui")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:updateEntityHeadUI()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:hideEntityHeadUI()
      entity:closePlayerHeadGangIcon()
    end
  end)
else
  require("server.player.player_entity_head_ui")
  require("server.player.packet_entity_head_ui")
  require("server.entity.entity_entity_head_ui")
  require("server.gate_entity_head_ui")
  require("server.gm_entity_head_ui")
end
local handlers = {}

function handlers.OnPlayerLogin(player)
  player:setValue("entityHeadUI", {
    name = player.name,
    visible = true
  })
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

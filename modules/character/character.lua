require("common.entity_character")
require("common.event_character")
require("common.define_character")
require("common.ability.ability_manager")
require("common.ability.item_ability.auto_aim")
require("common.ability.item_ability.aim_helper")
if World.isClient then
  require("client.player.player_character")
  require("client.player.packet_character")
  require("client.entity.entity_character")
  require("client.entity.entity_value_func_character")
  require("client.gate_character")
  require("client.gm_character")
  require("client.hit_box_helper")
else
  require("server.player.player_character")
  require("server.player.packet_character")
  require("server.entity.entity_character")
  require("server.gate_character")
  require("server.gm_character")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

require("common.entity_battle")
require("common.event_battle")
require("common.define_battle")
if World.isClient then
  require("client.player.player_battle")
  require("client.player.packet_battle")
  require("client.entity.entity_battle")
  require("client.entity.entity_value_func_battle")
  require("client.gate_battle")
  require("client.gm_battle")
else
  require("server.player.player_battle")
  require("server.player.packet_battle")
  require("server.entity.entity_battle")
  require("server.gate_battle")
  require("server.gm_battle")
  require("server.drop_item")
  local BattleFieldManager = require("server.battle_field_manager")
  BattleFieldManager:init()
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

require("common.entity_weapon")
require("common.event_weapon")
require("common.define_weapon")
require("common.config.weapon_config")
local sound = require("common.config.sound_config")
sound:init()
if World.isClient then
  require("client.effect.weapon_effect_helper")
  require("client.player.player_weapon")
  require("client.player.packet_weapon")
  require("client.entity.entity_weapon")
  require("client.entity.entity_value_func_weapon")
  require("client.gate_weapon")
  require("client.gm_weapon")
else
  require("server.player.player_weapon")
  require("server.player.packet_weapon")
  require("server.entity.entity_weapon")
  require("server.gate_weapon")
  require("server.gm_weapon")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

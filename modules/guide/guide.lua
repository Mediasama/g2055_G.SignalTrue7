require("common.entity_guide")
require("common.event_guide")
require("common.define_guide")
require("common.config.guide_config")
if World.isClient then
  require("client.player.player_guide")
  require("client.player.packet_guide")
  require("client.entity.entity_guide")
  require("client.entity.entity_value_func_guide")
  require("client.entity.guide_enemy")
  require("client.guide_helper")
  require("client.gm_guide")
else
  require("server.player.player_guide")
  require("server.player.packet_guide")
  require("server.entity.entity_guide")
  require("server.gm_guide")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

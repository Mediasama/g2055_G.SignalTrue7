require("common.entity_helper_common")
require("common.event_helper_common")
require("common.define_helper_common")
if World.isClient then
  require("lib_g2055")
  require("client.player.player_helper_common")
  require("client.player.packet_helper_common")
  require("client.entity.entity_helper_common")
  require("client.entity.entity_value_func_helper_common")
  require("client.gate_helper_common")
  require("client.gm_helper_common")
else
  require("lib_g2055_server")
  require("server.player.player_helper_common")
  require("server.player.packet_helper_common")
  require("server.entity.entity_helper_common")
  require("server.gate_helper_common")
  require("server.gm_helper_common")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

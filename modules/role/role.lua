require("common.entity_role")
require("common.event_role")
require("common.define_role")
if World.isClient then
  require("client.player.player_role")
  require("client.player.packet_role")
  require("client.entity.entity_role")
  require("client.entity.entity_value_func_role")
  require("client.gate_role")
  require("client.gm_role")
else
  require("server.player.player_role")
  require("server.player.packet_role")
  require("server.entity.entity_role")
  require("server.gate_role")
  require("server.gm_role")
end
local handlers = {}

function handlers.onPlayerLogout(player)
  if player then
    if player.logicTimer then
      player.logicTimer()
      player.logicTimer = nil
    end
    if player.startHealthTimer then
      player.startHealthTimer()
      player.startHealthTimer = nil
    end
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

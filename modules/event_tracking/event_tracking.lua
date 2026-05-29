require("common.entity_event_tracking")
require("common.event_event_tracking")
require("common.define_event_tracking")
require("common.player.player_event_tracking")
require("common.player.player_common_event")
require("common.player.player_gang_event")
if World.isClient then
  require("client.player.player_event_tracking")
  require("client.player.packet_event_tracking")
  require("client.entity.entity_event_tracking")
  require("client.entity.entity_value_func_event_tracking")
  require("client.gate_event_tracking")
  require("client.gm_event_tracking")
else
  require("server.player.player_event_tracking")
  require("server.player.packet_event_tracking")
  require("server.entity.entity_event_tracking")
  require("server.gate_event_tracking")
  require("server.gm_event_tracking")
end
local GameReport = T(Game, "Report")
local eventConfig = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/report.csv", 2)
local keyConfig = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/reportKeyFuncConvert.csv", 2)
GameReport:loadConfig(eventConfig, keyConfig)
local handlers = {}

function handlers.OnPlayerLogin(player)
  player:evt_onPlayerLogin()
end

function handlers.onPlayerLogout(player)
  player:evt_onPlayerLogout()
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

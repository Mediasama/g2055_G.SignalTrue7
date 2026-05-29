require("common.define_currency")
require("common.coin_currency")
require("common.event_currency")
require("common.player_currency")
if World.isClient then
  require("client.player.player_currency")
  require("client.gm_currency")
else
  require("server.player.player_currency")
  require("server.gm_currency")
end
local handlers = {}

function handlers.defaultSetting()
  return {
    settingKey = "currencySetting"
  }
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

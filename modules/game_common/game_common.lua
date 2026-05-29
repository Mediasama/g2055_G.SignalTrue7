require("common.entity_game_common")
require("common.event_game_common")
require("common.define_game_common")
require("common.config.exchange_config")
if World.isClient then
  require("client.camera.camera_manager")
  require("client.player.packet_game_common")
  require("client.entity.entity_value_func_game_common")
  require("client.gm_game_common")
  require("client.helper.entity_collider_helper")
else
  require("server.player.player_game_common")
  require("server.player.packet_game_common")
  require("server.gm_game_common")
end
local handlers = {}

function handlers.defaultSetting()
  return {
    settingKey = "gameCommonSetting"
  }
end

handlers.playerLoginFailCounter = 0

function handlers.ENTITY_ENTER(context)
  local ok, ret = Lib.XPcall(function()
    local entity = context.obj1
    if entity and entity:isValid() and entity.isPlayer then
      entity:setDefaultWeapon()
      entity:syncPlayerData()
      local BattleFieldManager = require("server.battle_field_manager")
      BattleFieldManager:joinBattleFiled(entity)
      local StateManager = require("common.state.state_manager")
      entity.stateManager = StateManager.new(entity)
    end
  end)
  if not ok then
    handlers.playerLoginFailCounter = handlers.playerLoginFailCounter + 1
    print("============================  handlers.ENTITY_ENTER(context) playerLoginFailCounter: ", handlers.playerLoginFailCounter)
    context.obj1.loginFail = true
    perror(ret)
    Game.SendStartGame()
    Game.KickOutPlayer(context.obj1)
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

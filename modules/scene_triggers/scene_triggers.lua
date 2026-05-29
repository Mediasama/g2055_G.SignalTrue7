require("common.entity_scene_triggers")
require("common.event_scene_triggers")
require("common.config.scene_triggers_config")
require("common.define_scene_triggers")
if World.isClient then
  require("client.player.player_scene_triggers")
  require("client.player.packet_scene_triggers")
  require("client.entity.entity_scene_triggers")
  require("client.entity.entity_value_func_scene_triggers")
  require("client.gate_scene_triggers")
  require("client.gm_scene_triggers")
else
  require("server.player.player_scene_triggers")
  require("server.player.packet_scene_triggers")
  require("server.entity.entity_scene_triggers")
  require("server.gate_scene_triggers")
  require("server.gm_scene_triggers")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local SceneTriggersManager = require("server.scene_triggers_manager")
  SceneTriggersManager.Instance():loadTriggers()
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

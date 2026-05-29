require("common.entity_bastion_ownership")
require("common.entity_bastion_vault")
require("common.entity_bastion_closet")
require("common.entity_bastion_defense")
require("common.entity_bastion_defense_property")
require("common.entity_bastion_garage")
require("common.entity_bastion_armory")
require("common.entity_bastion_guide")
require("common.entity_bastion_hacker")
require("common.config.bastion_config")
require("common.event_bastion")
require("common.define_bastion")
require("common.bastion_utils")
require("common.config.doors_config")
if World.isClient then
  require("client.ui.ui_handler_bastion")
  require("client.player.player_bastion")
  require("client.player.packet_bastion")
  require("client.entity.entity_bastion")
  require("client.entity.entity_value_func_bastion")
  require("client.gate_bastion")
  require("client.gm_bastion")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:updateBastionFacilityInfo()
      entity:updateBastionDefenseInfo()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      local cfg = entity:cfg() or {}
      local outLine = cfg.outLine
      if outLine then
        local color = outLine.color or {}
        local width = outLine.width or 0.001
        local lineColor = {
          color.r / 255,
          color.g / 255,
          color.b / 255,
          color.a / 255
        }
        entity:setEdgeWithDepth(true, lineColor, width)
      end
    end
  end)
else
  require("server.player.player_bastion")
  require("server.player.packet_bastion")
  require("server.entity.entity_bastion")
  require("server.gate_bastion")
  require("server.gm_bastion")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local BastionManager = require("server.bastion_manager")
  BastionManager.Instance():loadBastions()
end

function handlers.PLAYER_DIE_TRIGGER_EVENT(context)
  local player = context.player
  local BastionManager = require("server.bastion_manager")
  BastionManager.Instance():responsePlayerDie(player.platformUserId)
  local packet = {
    pid = "S2C_NotifyPlayDie",
    userId = player.platformUserId,
    objID = player.objID
  }
  WorldServer.BroadcastPacket(packet)
end

function handlers.OnPlayerLogin(player)
  player:initBastion()
end

function handlers.onPlayerLogout(player)
  player:releaseBastion()
  player:sendPacketToTracking({
    pid = "S2C_HideBastionIcon",
    userId = player.platformUserId
  }, false)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

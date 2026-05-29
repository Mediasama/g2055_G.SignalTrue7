require("common.entity_gangs")
require("common.event_gangs")
require("common.config.gang_icon_config")
require("common.define_gangs")
if World.isClient then
  require("client.player.player_gangs")
  require("client.player.packet_gangs")
  require("client.entity.entity_gangs")
  require("client.entity.entity_value_func_gangs")
  require("client.gate_gangs")
  require("client.gm_gangs")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() and entity.isPlayer then
      print(">>>>>>>>>>>>>>>>>>>>>>>>>  EVENT_ENTITY_SPAWN ", objID, entity.platformUserId)
      entity:resetHeadTextHeight()
      entity:updatePlayerCircle()
    end
  end)
else
  require("server.player.player_gangs")
  require("server.player.packet_gangs")
  require("server.entity.entity_gangs")
  require("server.gate_gangs")
  require("server.gm_gangs")
end
local handlers = {}

function handlers.onPlayerLogout(player)
  local m_TerritoryManager = require("server.territory_manager_server")
  m_TerritoryManager:getInstance():onPlayerLogout(player)
  local m_AreaManager = require("server.area_manager_server")
  m_AreaManager:getInstance():onPlayerLogout(player)
  player:onExitClearGangInfo()
end

function handlers.OnPlayerLogin(player)
  local GangsManager = require("server.gangs_manager_server")
  GangsManager:getInstance():sendTopGang(player, GangsManager:getInstance().topGang)
end

function handlers.getPlayerGangMemberList(player)
  if player and player:isValid() then
    return player:getGangMemberList()
  end
end

function handlers:playerHasGang()
  if World.isClient then
    return Me:hasGang()
  else
    return false
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

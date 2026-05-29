require("common.entity_territory")
require("common.event_territory")
require("common.config.territory_config")
require("common.config.territory_income_config")
require("common.define_territory")
if World.isClient then
  require("client.player.player_territory")
  require("client.player.packet_territory")
  require("client.entity.entity_territory")
  require("client.entity.entity_value_func_territory")
  require("client.gate_territory")
  require("client.gm_territory")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() then
      entity:updateEntityEnter()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() then
      entity:onDestroyTerritory()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(player)
    if player.objID == Me.objID then
      Me:syncAllTerritoryEntity()
    end
  end)
else
  require("server.player.player_territory")
  require("server.player.packet_territory")
  require("server.entity.entity_territory")
  require("server.territory_manager_server")
  require("server.gate_territory")
  require("server.gm_territory")
end
local handlers = {}

function handlers.END_MAP_LOADING(context)
  local m_TerritoryManager = require("server.territory_manager_server")
  m_TerritoryManager:getInstance():createTerritoryEntity()
  local m_AreaManager = require("server.area_manager_server")
  m_AreaManager:getInstance():createAreaEntity()
end

local TerritoryServer = T(Lib, "TerritoryServer")
local TattooServer = T(Lib, "TattooServer")

function handlers.PLAYER_DIE_TRIGGER_EVENT(context)
  TerritoryServer:export_interruptTerritoryOccupy(context.player)
  TattooServer:export_interruptTattoo(context.player)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

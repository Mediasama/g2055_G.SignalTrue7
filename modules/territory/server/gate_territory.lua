local m_TerritoryManager = require("server.territory_manager_server")
local TerritoryServer = T(Lib, "TerritoryServer")

function TerritoryServer:export_interruptTerritoryOccupy(player)
  m_TerritoryManager:getInstance():interruptTerritoryOccupy(player)
end

function TerritoryServer:export_onGangDismiss(gangId)
  m_TerritoryManager:getInstance():onGangDismiss(gangId)
end

function TerritoryServer:export_enterGang(userId, gangId)
  m_TerritoryManager:getInstance():enterGang(userId, gangId)
end

function TerritoryServer:export_getGangTerritoryIds(gangId)
  return m_TerritoryManager:getInstance():getGangTerritoryIds(gangId)
end

function TerritoryServer:export_getAward(player, gangId)
  return m_TerritoryManager:getInstance():getAward(player, gangId)
end

return TerritoryServer

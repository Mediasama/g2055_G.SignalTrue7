local m_TerritoryManager = require("server.territory_manager_server")
local handles = T(Player, "PackageHandlers")

function handles:onRequestOccupy(packet)
  if self:isPlayerInDieState() then
    return
  end
  local code = m_TerritoryManager:getInstance():requestOccupy(self, packet.id)
  return {code = code}
end

function handles:onGetTerritoryOccupyInfo(packet)
  return {
    data = m_TerritoryManager:getInstance():getTerritoryOccupyInfo()
  }
end

function handles:onGetAllTerritoryEntity()
  return {
    data = m_TerritoryManager:getInstance():getAllTerritoryEntity()
  }
end

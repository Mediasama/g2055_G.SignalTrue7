local GangsServer = T(Lib, "GangsServer")
local GangsManager = require("server.gangs_manager_server")

function GangsServer:export_reportGangTerritoryChange(gangId, isAdd)
  GangsManager:getInstance():report_team_info_territory_change(gangId, isAdd)
end

function GangsServer:export_gangTerritoryChange(gangId, territoryId, isAdd)
  GangsManager:getInstance():gangTerritoryChange(gangId, territoryId, isAdd)
end

return GangsServer

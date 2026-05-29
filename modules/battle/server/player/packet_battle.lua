local BattleFieldManager = require("server.battle_field_manager")
local handles = T(Player, "PackageHandlers")

function handles:joinBattle(packet)
  BattleFieldManager:joinBattleFiled(self)
end

function handles:getMatchData(packet)
  local filed = BattleFieldManager:getMatchBattleFiled()
  local data
  if filed then
    data = filed:getMathData()
  else
    data = {}
    data.totalCount = 0
    data.totalTime = World.cfg.match.battleTime
    data.waitTime = World.cfg.match.waitTime
  end
  self:sendPacket({
    pid = "receiveMatchData",
    mathData = data
  })
end

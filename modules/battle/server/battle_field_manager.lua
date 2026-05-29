local BattleFieldManager = {}
local LuaTimer = T(Lib, "LuaTimer")
local BattleField = require("server.battle_field")
local battleFieldList = {}

function BattleFieldManager:init()
  self.updateTimer = World.LightTimer("updateTimer", 1, function()
    self:update(0.05)
    return true
  end)
end

function BattleFieldManager:onPlayerLogin(player)
  local isPlayerInBattle = false
  for _, battleField in pairs(battleFieldList) do
    if battleField:isPlayerInBattle(player.platformUserId) then
      battleField:enter(player)
      isPlayerInBattle = true
      break
    end
  end
  if not isPlayerInBattle then
    Plugins.CallTargetPluginFunc("arena", "requestBattleInfoByUserId", player.platformUserId)
  end
end

local battleFieldIndex = 0

function BattleFieldManager:create()
  battleFieldIndex = battleFieldIndex + 1
  local param = {}
  param.uid = battleFieldIndex
  param.waitTime = World.cfg.match.waitTime
  param.battleTime = World.cfg.match.battleTime
  local bf = BattleField.new(self, param)
  battleFieldList[battleFieldIndex] = bf
  return bf
end

function BattleFieldManager:update(dt)
  for _, battleField in pairs(battleFieldList) do
    battleField:update(dt)
  end
end

function BattleFieldManager:getBattleFieldList()
  return battleFieldList
end

function BattleFieldManager:remove(uid)
  if battleFieldList[uid] then
  end
  battleFieldList[uid] = nil
end

function BattleFieldManager:getMatchBattleFiled()
  for _, battleField in pairs(battleFieldList) do
    return battleField
  end
end

function BattleFieldManager:joinBattleFiled(player)
  local battleField = self:getMatchBattleFiled()
  battleField = battleField or self:create()
  battleField:enter(player)
end

function BattleFieldManager:isInBattle(platformUserId)
  for _, battleField in pairs(battleFieldList) do
    if battleField:isPlayerInBattle(platformUserId) then
      return true
    end
  end
  return false
end

return BattleFieldManager

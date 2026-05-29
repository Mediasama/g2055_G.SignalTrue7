local AreaObjectBase = Lib.class("AreaObjectBase")

function AreaObjectBase:ctor(entity, id, territoryCfgId)
  self.entity = entity
  self.areaId = id
  self.territoryCfgId = territoryCfgId
  self.triggerPlayer = {}
end

function AreaObjectBase:recordTriggerPlayer(player, operateType)
  if operateType == Define.TerritoryTriggerType.Enter then
    self.triggerPlayer[player.platformUserId] = true
  else
    self.triggerPlayer[player.platformUserId] = nil
  end
end

function AreaObjectBase:onPlayerLogout(player)
  self:recordTriggerPlayer(player, Define.TerritoryTriggerType.Exit)
end

function AreaObjectBase:updateAreaTerritoryInfo(id)
  if id == self.territoryCfgId then
    for k, v in pairs(self.triggerPlayer) do
      local player = Game.GetPlayerByUserId(k)
      if player and player:isValid() then
        player:updateOccupyInfo(self.territoryCfgId, self:getAreaData())
      end
    end
  end
end

local m_TerritoryManager = require("server.territory_manager_server")

function AreaObjectBase:getAreaData()
  return m_TerritoryManager:getInstance():getTerritoryOccupyInfoById(self.territoryCfgId)
end

return AreaObjectBase

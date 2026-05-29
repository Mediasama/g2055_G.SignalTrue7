local TerritoryConfig = T(Config, "TerritoryConfig")
local Territory_object_base = require("common.territory_object.territory_object_base")
local TerritoryManager = Lib.class("TerritoryManager")
local instance

function TerritoryManager:getInstance()
  if instance == nil then
    instance = TerritoryManager.new()
  end
  return instance
end

function TerritoryManager:ctor()
  self:init()
end

function TerritoryManager:init()
  self.territoryObject = {}
  self.allTerritoryEntity = {}
  World.Timer(1, function()
    self:update()
    return true
  end)
end

function TerritoryManager:update()
  for k, v in pairs(self.territoryObject) do
    v:updateStatus()
  end
end

function TerritoryManager:onTrigger(target, player, operateType)
  local territoryData
  if self.territoryObject[target.objID] then
    self.territoryObject[target.objID]:recordTriggerPlayer(player, operateType)
    if operateType == Define.TerritoryTriggerType.Enter then
      territoryData = self.territoryObject[target.objID]:getTerritoryData()
    end
  else
    return
  end
  player:sendPacket({
    pid = "onTerritoryTriggerOperation",
    operateType = operateType,
    objID = target.objID,
    territoryData = territoryData
  })
end

function TerritoryManager:createTerritoryEntity()
  local cfg = TerritoryConfig:getAllCfgs()
  local map = World.CurWorld:getMap()
  for k, v in pairs(cfg) do
    local pos = Lib.copy(v.pos)
    local trigger = EntityServer.Create({
      cfgName = v.cfg_name,
      map = map,
      pos = pos
    })
    if trigger then
      local territoryObject = Territory_object_base.new(trigger, v.id)
      self.territoryObject[trigger.objID] = territoryObject
      self.allTerritoryEntity[#self.allTerritoryEntity + 1] = trigger.objID
    end
  end
end

function TerritoryManager:requestOccupy(player, id)
  if self.territoryObject[id] then
    return self.territoryObject[id]:playerRequestOccupy(player)
  end
  return Define.TerritoryPacketCode.ErrorRequest
end

function TerritoryManager:onPlayerLogout(player)
  for k, v in pairs(self.territoryObject) do
    v:onPlayerLogout(player)
  end
end

function TerritoryManager:getTerritoryOccupyInfo()
  local data = {}
  for k, v in pairs(self.territoryObject) do
    data[#data + 1] = v:getOccupyInfo()
  end
  return data
end

function TerritoryManager:getTerritoryOccupyInfoById(id)
  for k, v in pairs(self.territoryObject) do
    if v.cfg.id == id then
      return v:getOccupyInfo()
    end
  end
  return nil
end

function TerritoryManager:onGangDismiss(gangId)
  for k, v in pairs(self.territoryObject) do
    v:onGangDismiss(gangId)
  end
end

function TerritoryManager:interruptTerritoryOccupy(player)
  for k, v in pairs(self.territoryObject) do
    v:interruptTerritoryOccupy(player)
  end
end

function TerritoryManager:enterGang(userId, gangId)
  for k, v in pairs(self.territoryObject) do
    v:enterGang(userId, gangId)
  end
end

function TerritoryManager:getGangTerritoryIds(gangId)
  local ids = ""
  for k, v in pairs(self.territoryObject) do
    local id = v:getGangTerritoryId(gangId)
    if id then
      ids = ids .. id .. ","
    end
  end
  return ids
end

function TerritoryManager:getAward(player, gangId)
  for k, v in pairs(self.territoryObject) do
    local data = v:getAward(player, gangId)
    if data then
      return data
    end
  end
  return nil
end

function TerritoryManager:getAllTerritoryEntity()
  return self.allTerritoryEntity
end

return TerritoryManager

local TerritoryConfig = T(Config, "TerritoryConfig")
local Area_object_base = require("common.area_object.area_object_base")
local AreaManager = Lib.class("AreaManager")
local instance

function AreaManager:getInstance()
  if instance == nil then
    instance = AreaManager.new()
  end
  return instance
end

function AreaManager:ctor()
  self:init()
end

function AreaManager:init()
  self.areaObject = {}
end

function AreaManager:createAreaEntity()
  local cfg = TerritoryConfig:getAllCfgs()
  local map = World.CurWorld:getMap()
  for k, v in pairs(cfg) do
    local pos = Lib.copy(v.area_entity_pos)
    local trigger = EntityServer.Create({
      cfgName = v.area_cfg_name,
      map = map,
      pos = pos
    })
    if trigger then
      local areaObject = Area_object_base.new(trigger, v.area_id, v.id)
      self.areaObject[trigger.objID] = areaObject
    end
  end
end

function AreaManager:update()
end

function AreaManager:onTrigger(target, player, operateType)
  local areaObjectData
  if self.areaObject[target.objID] then
    self.areaObject[target.objID]:recordTriggerPlayer(player, operateType)
    if operateType == Define.TerritoryTriggerType.Enter then
      areaObjectData = self.areaObject[target.objID]:getAreaData()
    end
  else
    return
  end
  player:sendPacket({
    pid = "onAreaTriggerOperation",
    operateType = operateType,
    objID = target.objID,
    areaObjectData = areaObjectData
  })
end

function AreaManager:updateAreaTerritoryInfo(territoryId)
  for k, v in pairs(self.areaObject) do
    v:updateAreaTerritoryInfo(territoryId)
  end
end

function AreaManager:onPlayerLogout(player)
  for k, v in pairs(self.areaObject) do
    v:onPlayerLogout(player)
  end
end

return AreaManager

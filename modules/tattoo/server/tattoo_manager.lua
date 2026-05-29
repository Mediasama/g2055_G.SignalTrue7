local TattooConfig = T(Config, "TattooConfig")
local tattoo_object_base = require("common.tattoo.tattoo_object_base")
local TattooManager = Lib.class("TattooManager")
local instance

function TattooManager:getInstance()
  if instance == nil then
    instance = TattooManager.new()
  end
  return instance
end

function TattooManager:ctor()
  self:init()
end

function TattooManager:init()
  self.tattooObject = {}
  World.Timer(1, function()
    self:update()
    return true
  end)
end

function TattooManager:update()
  for k, v in pairs(self.tattooObject) do
    v:updateStatus()
  end
end

function TattooManager:requestTattoo(player, objID, tattooId)
  if self.tattooObject and self.tattooObject[objID] then
    return self.tattooObject[objID]:requestTattoo(player, tattooId)
  end
end

function TattooManager:onTrigger(target, player, operateType)
  local tattooData
  if self.tattooObject[target.objID] then
    self.tattooObject[target.objID]:recordTriggerPlayer(player, operateType)
    if operateType == Define.TerritoryTriggerType.Enter then
      tattooData = self.tattooObject[target.objID]:getTattooData(player)
    end
  else
    return
  end
  player:sendPacket({
    pid = "onTattooTriggerOperation",
    operateType = operateType,
    objID = target.objID,
    tattooData = tattooData
  })
end

function TattooManager:createTattooEntity()
  local cfg = TattooConfig:getAllCfgs()
  local map = World.CurWorld:getMap()
  for k, v in pairs(cfg) do
    local pos = Lib.copy(v.pos)
    local trigger = EntityServer.Create({
      cfgName = v.cfg_name,
      map = map,
      pos = pos,
      ry = v.rotation.y,
      rp = v.rotation.x,
      rr = v.rotation.z
    })
    if trigger then
      local tattooObject = tattoo_object_base.new(trigger, v.id)
      self.tattooObject[trigger.objID] = tattooObject
      trigger:setRotation(v.rotation.y, v.rotation.x, v.rotation.z)
    end
  end
end

function TattooManager:onPlayerLogout(player)
  for k, v in pairs(self.tattooObject) do
    v:onPlayerLogout(player)
  end
end

function TattooManager:interruptTattoo(player)
  for k, v in pairs(self.tattooObject) do
    v:interruptTattoo(player)
  end
end

return TattooManager

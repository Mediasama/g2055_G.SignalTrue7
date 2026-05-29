local SceneTriggersConfig = T(Config, "SceneTriggersConfig")
local SceneTriggersManager = Lib.class("SceneTriggersManager")
local _instance

function SceneTriggersManager.Instance()
  if _instance == nil then
    _instance = SceneTriggersManager.new()
    _instance:init()
  end
  return _instance
end

function SceneTriggersManager:ctor()
  self.triggerDict = {}
  self.loaded = false
end

function SceneTriggersManager:init()
end

function SceneTriggersManager:getTriggerDict()
  return self.triggerDict
end

function SceneTriggersManager:getTrigger(id)
  return self.triggerDict[id]
end

function SceneTriggersManager:setTrigger(id, trigger)
  if not id then
    return
  end
  if not trigger then
    return
  end
  self.triggerDict[id] = trigger
end

function SceneTriggersManager:removeTrigger(id)
  self.triggerDict[id] = nil
end

function SceneTriggersManager:loadTriggers()
  if self.loaded then
    return
  end
  local map = World.CurWorld:getMap()
  local triggerCFGs = SceneTriggersConfig:getAllCfgs()
  for i, triggerCFG in pairs(triggerCFGs) do
    if triggerCFG.entity_cfg then
      local param = {
        cfgName = triggerCFG.entity_cfg,
        map = map,
        pos = triggerCFG.position,
        ry = triggerCFG.rotation.y,
        rp = triggerCFG.rotation.x,
        rr = triggerCFG.rotation.z
      }
      local trigger = EntityServer.Create(param)
      trigger:setRotation(triggerCFG.rotation.y, triggerCFG.rotation.x, triggerCFG.rotation.z)
      self:setTrigger(triggerCFG.id, trigger)
    end
  end
  self.loaded = true
end

return SceneTriggersManager

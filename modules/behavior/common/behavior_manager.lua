local BehaviorFactory = require("common.behavior_factory")
local BehaviorManager = Lib.class("BehaviorManager")
local _instance

function BehaviorManager.Instance()
  if _instance == nil then
    _instance = BehaviorManager.new()
    _instance:init()
  end
  return _instance
end

function BehaviorManager:ctor()
  self._behaviorList = {}
  self._timer = nil
end

function BehaviorManager:init()
  self:startUpdateTimer()
end

function BehaviorManager:destroy()
  self:stopUpdateTimer()
end

function BehaviorManager:startUpdateTimer()
  self:stopUpdateTimer()
  self._timer = World.Timer(1, function()
    self:update(1)
    return true
  end)
end

function BehaviorManager:stopUpdateTimer()
  if self._timer and type(self._timer) == "function" then
    self._timer()
  end
end

function BehaviorManager:runBehavior(behavior, param)
  behavior:runWithParam(param)
  table.insert(self._behaviorList, behavior)
end

function BehaviorManager:getBehaviorList(targetLocator)
  local list = {}
  for index, behavior in pairs(self._behaviorList) do
    local behaviorTargetLocator = behavior:getOwnerLocator()
    if behaviorTargetLocator and behaviorTargetLocator.type == targetLocator.type and behaviorTargetLocator.id == targetLocator.id then
      table.insert(list, behavior)
    end
  end
  return list
end

function BehaviorManager:stopTargetBehavior(targetLocator)
  local behaviorList = self:getBehaviorList(targetLocator)
  for i, behavior in pairs(behaviorList) do
    behavior:stop()
  end
end

function BehaviorManager:update(timeDelta)
  for index, behavior in pairs(self._behaviorList) do
    behavior:update(timeDelta)
  end
  for index = #self._behaviorList, 1, -1 do
    local behavior = self._behaviorList[index]
    if behavior:getState() == Define.Behavior.State.Finish then
      behavior:destroy()
      table.remove(self._behaviorList, index)
    end
  end
end

function BehaviorManager:runBehaviorWithParam(param)
  local behavior = BehaviorFactory.Instance():create(param.behaviorCreateParam)
  if behavior then
    self:runBehavior(behavior, param.behaviorStartParam)
  end
end

function BehaviorManager:runBehaviorListWithParam(targetLocator, operatorLocator, behaviorCreateParamList, synchronous)
  local targetUnit = World.CurWorld:getUnit(targetLocator)
  if not targetUnit then
    return
  end
  if not synchronous and targetUnit:isRunningBehavior() then
    return
  end
  for i, createParam in pairs(behaviorCreateParamList) do
    local startParam = {}
    startParam.targetLocator = targetLocator
    startParam.operatorLocator = operatorLocator
    local param = {}
    param.behaviorCreateParam = createParam
    param.behaviorStartParam = startParam
    BehaviorManager.Instance():runBehaviorWithParam(param)
  end
end

function BehaviorManager:tryOperateUnit(targetLocator, operatorLocator, operationList, itemId, synchronous)
  local targetUnit = World.CurWorld:getUnit(targetLocator)
  if not targetUnit then
    return false
  end
  for i, operation in pairs(operationList) do
    local stateMask = operation.stateMask or {}
    if targetUnit:isStateMaskMatch(stateMask) then
      local behaviorList = operation.behaviorList or {}
      BehaviorManager.Instance():runBehaviorListWithParam(targetLocator, operatorLocator, behaviorList, synchronous)
      return true
    end
  end
  return false
end

function BehaviorManager:operateUnit(targetLocator, operatorLocator, type, itemId, synchronous)
  synchronous = synchronous or false
  local targetUnit = World.CurWorld:getUnit(targetLocator)
  if not targetUnit then
    return false
  end
  local operationList = targetUnit:getOperationList(type) or {}
  return self:tryOperateUnit(targetLocator, operatorLocator, operationList, itemId, synchronous)
end

return BehaviorManager

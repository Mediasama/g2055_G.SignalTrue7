local BehaviorBase = require("common.behavior_base")
local BehaviorOperateTerritoryOccupy = Lib.class("BehaviorOperateTerritoryOccupy", BehaviorBase)

function BehaviorOperateTerritoryOccupy:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.OperateTerritoryOccupy
end

function BehaviorOperateTerritoryOccupy:start(startParam)
  if World.isClient then
    self:stop()
  else
    local curWorld = World.CurWorld
    local operatorLocator = startParam.operatorLocator
    local targetLocator = startParam.targetLocator
    local operator = curWorld:getUnit(operatorLocator)
    local target = curWorld:getUnit(targetLocator)
    local param = self._createParam
    if target and target:isValid() and operator and operator.isPlayer and operator:isValid() then
      if operator:isDriving() and param.operateType == Define.TerritoryTriggerType.Enter then
        return
      end
      local m_TerritoryManager = require("server.territory_manager_server")
      m_TerritoryManager:getInstance():onTrigger(target, operator, param.operateType)
    end
    self:stop()
  end
end

return BehaviorOperateTerritoryOccupy

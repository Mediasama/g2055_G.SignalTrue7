local BehaviorBase = require("common.behavior_base")
local BehaviorOperateArea = Lib.class("BehaviorOperateArea", BehaviorBase)

function BehaviorOperateArea:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.OperateArea
end

function BehaviorOperateArea:start(startParam)
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
      local m_areaManager = require("server.area_manager_server")
      m_areaManager:getInstance():onTrigger(target, operator, param.operateType)
    end
    self:stop()
  end
end

return BehaviorOperateArea

local BehaviorBase = require("common.behavior_base")
local BehaviorOperateBastionDefense = Lib.class("BehaviorOperateBastionDefense", BehaviorBase)

function BehaviorOperateBastionDefense:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.OperateBastionDefense
end

function BehaviorOperateBastionDefense:start(startParam)
  if World.isClient then
    self:stop()
  else
    local curWorld = World.CurWorld
    local operatorLocator = startParam.operatorLocator
    local targetLocator = startParam.targetLocator
    local operator = curWorld:getUnit(operatorLocator)
    local target = curWorld:getUnit(targetLocator)
    if target and target:isValid() and operator and operator.isPlayer and operator:isValid() then
      local facility = target
      local player = operator
      local param = self._createParam
      local operateType = param.operateType or Define.Bastion.Facility.TriggerType.None
      if player:isDriving() and operateType == Define.Bastion.Facility.TriggerType.Open then
        return
      end
      local ownerId = facility:getBastionOwnerId()
      if not ownerId then
        return
      end
      local defenseType = param.defenseType
      local operateType = param.operateType
      local param = param.param
      local operatorId = operator.platformUserId
      player:triggerBastionDefense(operateType, ownerId, operatorId, defenseType, param, target.objID)
    end
    self:stop()
  end
end

return BehaviorOperateBastionDefense

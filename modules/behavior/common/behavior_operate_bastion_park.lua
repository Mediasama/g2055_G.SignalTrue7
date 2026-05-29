local BehaviorBase = require("common.behavior_base")
local BehaviorOperateBastionPark = Lib.class("BehaviorOperateBastionPark", BehaviorBase)

function BehaviorOperateBastionPark:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.OperateBastionPark
end

function BehaviorOperateBastionPark:start(startParam)
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
      local facilityType = facility:getBastionFacilityType()
      local ownerId = facility:getBastionOwnerId()
      if not ownerId then
        return
      end
      if ownerId ~= player.platformUserId then
        return
      end
      local useCarInfo = operator:getInUseCar()
      if not useCarInfo then
        return
      end
      local carId = useCarInfo.id
      if not carId then
        return
      end
      local packetParam = {
        operateType = param.operateType or Define.Bastion.Facility.TriggerType.None,
        facilityType = facilityType,
        ownerId = ownerId,
        operatorId = player.platformUserId,
        objID = target.objID,
        triggerParam = param.triggerParam
      }
      player:S2C_TriggerBastionPark(packetParam)
    end
    self:stop()
  end
end

return BehaviorOperateBastionPark

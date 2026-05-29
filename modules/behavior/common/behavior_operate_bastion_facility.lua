local BehaviorBase = require("common.behavior_base")
local BehaviorOperateBastionFacility = Lib.class("BehaviorOperateBastionFacility", BehaviorBase)

function BehaviorOperateBastionFacility:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.OperateBastionFacility
end

function BehaviorOperateBastionFacility:start(startParam)
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
      local facilityType = facility:getBastionFacilityType()
      local ownerId = facility:getBastionOwnerId()
      if not ownerId then
        return
      end
      local packetParam = {
        operateType = operateType,
        facilityType = facilityType,
        ownerId = ownerId,
        operatorId = operator.platformUserId,
        objID = target.objID,
        triggerParam = param.triggerParam
      }
      if Define.Bastion.Facility.TriggerType.Open then
        player.isNearDoor = true
      elseif Define.Bastion.Facility.TriggerType.Close then
        player.isNearDoor = false
      end
      player:S2C_TriggerBastionFacility(packetParam)
    end
    self:stop()
  end
end

return BehaviorOperateBastionFacility

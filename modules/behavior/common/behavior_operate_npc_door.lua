local BehaviorBase = require("common.behavior_base")
local BehaviorOperateNpcDoor = Lib.class("BehaviorOperateNpcDoor", BehaviorBase)

function BehaviorOperateNpcDoor:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.OperateNpcDoor
end

function BehaviorOperateNpcDoor:start(startParam)
  if World.isClient then
    self:stop()
  else
    local curWorld = World.CurWorld
    local operatorLocator = startParam.operatorLocator
    local targetLocator = startParam.targetLocator
    local operator = curWorld:getUnit(operatorLocator)
    local target = curWorld:getUnit(targetLocator)
    if target and target:isValid() and operator and operator.isPlayer and operator:isValid() then
      local trigger = target
      local doorId = trigger:ndp_getID()
      local player = operator
      local param = self._createParam
      local operateType = param.operateType or Define.NPCDoor.Operate.Type.None
      if player:isDriving() and operateType == Define.NPCDoor.Operate.Type.Open then
        return
      end
      local from = param.from
      local triggerParam = param.triggerParam
      local operatorId = operator.platformUserId
      player:ndp_OperateNpcDoor(operateType, doorId, operatorId, from, triggerParam)
    end
    self:stop()
  end
end

return BehaviorOperateNpcDoor

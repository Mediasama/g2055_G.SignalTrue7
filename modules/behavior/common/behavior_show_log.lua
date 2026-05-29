local BehaviorBase = require("common.behavior_base")
local BehaviorShowLog = Lib.class("BehaviorShowLog", BehaviorBase)

function BehaviorShowLog:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.ShowLog
end

function BehaviorShowLog:start(startParam)
  if World.isClient then
    self:stop()
  else
    local curWorld = World.CurWorld
    local targetLocator = startParam.targetLocator
    local target = curWorld:getUnit(targetLocator)
    if target and target:isValid() then
      local text = self._createParam.text or ""
      Lib.logBastion(text, target:ndp_getID())
    end
    self:stop()
  end
end

return BehaviorShowLog

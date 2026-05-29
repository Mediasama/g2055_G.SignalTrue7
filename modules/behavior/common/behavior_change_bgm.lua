local BehaviorBase = require("common.behavior_base")
local BehaviorChangeBGM = Lib.class("BehaviorChangeBGM", BehaviorBase)

function BehaviorChangeBGM:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.ChangeBGM
end

function BehaviorChangeBGM:start(startParam)
  if World.isClient then
    self:stop()
  else
    local curWorld = World.CurWorld
    local operatorLocator = startParam.operatorLocator
    local operator = curWorld:getUnit(operatorLocator)
    if operator and operator.isPlayer and operator:isValid() then
      local player = operator
      local param = self._createParam
      local bgm = param.bgm or ""
      player:stg_S2C_ChangeBGM(bgm)
    end
    self:stop()
  end
end

return BehaviorChangeBGM

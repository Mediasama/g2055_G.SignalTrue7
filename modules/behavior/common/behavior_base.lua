local BehaviorBase = Lib.class("BehaviorBase")

function BehaviorBase:ctor(param)
  param = param or {}
  self._createParam = Lib.copy(param)
  self._type = Define.Behavior.Type.None
  self._state = Define.Behavior.State.None
  self._ownerLocator = nil
  self.delay = param.delay or 0
end

function BehaviorBase:destroy()
end

function BehaviorBase:getOwnerLocator()
  return self._ownerLocator
end

function BehaviorBase:setOwnerLocator(ownerLocator)
  self._ownerLocator = ownerLocator
end

function BehaviorBase:getState()
  return self._state
end

function BehaviorBase:setState(state)
  self._state = state
end

function BehaviorBase:runWithParam(param)
  self.startParam = param
  self:setState(Define.Behavior.State.Running)
  self:setOwnerLocator(self.startParam.targetLocator)
  if self.delay <= 0 then
    self:start(self.startParam)
  end
end

function BehaviorBase:start(param)
end

function BehaviorBase:update(timeDelta)
  if self:getState() == Define.Behavior.State.Running then
    if self.delay > 0 then
      self.delay = self.delay - timeDelta
      self._createParam.delay = self._createParam.delay - timeDelta
      if self.delay <= 0 then
        self._createParam.delay = 0
        self:start(self.startParam)
      end
    else
      self:onUpdate(timeDelta)
    end
  end
end

function BehaviorBase:stop()
  self:setState(Define.Behavior.State.Finish)
  self:onStop()
end

function BehaviorBase:onUpdate(timeDelta)
  self:stop()
end

function BehaviorBase:onStop()
end

function BehaviorBase:createSyncPacket(createParam, startParam)
  local packet = {
    pid = "SyncBehavior",
    behaviorCreateParam = createParam,
    behaviorStartParam = startParam
  }
  return packet
end

function BehaviorBase:lerpFloat(s, e, c)
  local past = c - s
  local total = e - s
  if 0 < total then
    local rate = past / total
    return math.max(0, math.min(1, rate))
  end
  return 1
end

return BehaviorBase

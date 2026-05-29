local LuaTimer = T(Lib, "LuaTimer")
local TerritoryEffect = Lib.class("TerritoryEffect")

function TerritoryEffect:ctor(pos, cfg)
  self:initEffect(pos, cfg)
end

function TerritoryEffect:initEffect(pos, cfg)
  local position = pos
  self.totalTime = cfg.totalTime
  self.type = cfg.type
  self.visible = false
  local effectName = cfg.effectName
  local num = cfg.num
  self.effectNum = num
  local yDelta = cfg.yDelta
  local totalAngle = 360
  self.effectNodes = {}
  for i = 1, num do
    local pos
    local rotationAngle = (i - 1) * totalAngle / num
    pos = Lib.v3(position.x, position.y + yDelta, position.z)
    local effect = EffectNode.Load(effectName)
    effect:setViewRange({
      x = 5,
      y = 1,
      z = 5
    })
    effect:setLocalQuaternion(Quaternion.fromEulerAngleVector(Lib.v3(0, rotationAngle, 0)))
    self.effectNodes[i] = {effect = effect, pos = pos}
  end
end

function TerritoryEffect:isVisible()
  return self.visible
end

function TerritoryEffect:scheduleEffect(index, parent, delta, leftNum)
  local i = index
  self.effectVisibleTimer = LuaTimer:scheduleTimerWithEnd(function()
    parent:addChild(self.effectNodes[i].effect)
    self.effectNodes[i].effect:setLocalPosition(self.effectNodes[i].pos)
    self.effectNodes[i].effect:restart()
    i = i + 1
  end, function()
    self.effectVisibleTimer = nil
  end, delta, leftNum)
end

function TerritoryEffect:hideEffect(parent)
  local visible = false
  self.visible = visible
  for i = 1, #self.effectNodes do
    parent:removeChild(self.effectNodes[i].effect)
  end
  if self.effectVisibleTimer then
    LuaTimer:cancel(self.effectVisibleTimer)
    self.effectVisibleTimer = nil
  end
  if self.midVisibleTimer then
    LuaTimer:cancel(self.midVisibleTimer)
    self.midVisibleTimer = nil
  end
end

function TerritoryEffect:setEffectVisible(visible, processInfo)
  local parent = World.CurMap:getScene():getRoot()
  if visible then
    if self.visible == visible then
      self:hideEffect(parent)
    end
    self.visible = visible
    if self.type == Define.TerritoryEffectType.NormalEffect or self.type == Define.TerritoryEffectType.NormalEffectMyCamp then
      for i = 1, #self.effectNodes do
        parent:addChild(self.effectNodes[i].effect)
        self.effectNodes[i].effect:setLocalPosition(self.effectNodes[i].pos)
      end
    elseif self.type == Define.TerritoryEffectType.OccupyEffect then
      local i = 1
      local delta = self.totalTime / 20 * 1000 / (self.effectNum + 1)
      parent:addChild(self.effectNodes[i].effect)
      self.effectNodes[i].effect:restart()
      self.effectNodes[i].effect:setLocalPosition(self.effectNodes[i].pos)
      i = i + 1
      self:scheduleEffect(i, parent, delta, self.effectNum - 1)
    else
      local i = 1
      local curTime = os.time()
      local finishTime = 1000 * processInfo.startTime + 1000 * processInfo.processTime / 20
      local seconds = finishTime - curTime * 1000
      if seconds < 0 then
        return
      end
      local delta = seconds / (self.effectNum + 1)
      parent:addChild(self.effectNodes[i].effect)
      self.effectNodes[i].effect:restart()
      self.effectNodes[i].effect:setLocalPosition(self.effectNodes[i].pos)
      i = i + 1
      self:scheduleEffect(i, parent, delta, self.effectNum - 1)
    end
  else
    if self.visible == visible then
      return
    end
    self:hideEffect(parent)
  end
end

return TerritoryEffect

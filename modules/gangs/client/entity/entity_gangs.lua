local Entity = _ENV.Entity

function Entity:updatePlayerCircle()
  local circleType = self:getCircleType()
  if self.platformUserId == Me.platformUserId then
    return
  end
  if circleType then
    self:showCircleEffect({type = circleType})
  end
end

function Entity:updateOtherPlayerCircle()
  local entityList = World.CurWorld:getAllEntity()
  for _, obj in pairs(entityList) do
    if obj.isPlayer and obj.platformUserId ~= Me.platformUserId then
      obj:updatePlayerCircle()
    end
  end
end

local circleEffectKey = "circleEffectKey"

function Entity:showCircleEffect(param)
  if not (param and param.type) or self.circleEffectType == param.type then
    return
  end
  local effectName = Define.GangPlayerCircleEffect[param.type]
  if not effectName then
    return
  end
  self:removeCircleEffect()
  self:addEffect(circleEffectKey, effectName, false, Vector3.new(0, 0, 0), 0, 1)
  self.circleEffectType = param.type
end

function Entity:removeCircleEffect()
  if not self:isValid() or not self.circleEffectType then
    return
  end
  self.circleEffectType = nil
  self:delEffect(circleEffectKey)
end

function Entity:resetHeadTextHeight()
  local haveGang = self:getValue("gangIconInfo") ~= nil
  local height = haveGang and (World.cfg.playerHeadTextHeight or 0.4) or World.cfg.playerHeadTextHeightNoGang or -0.35
  self:doSetProp("headTextHeight", height)
end

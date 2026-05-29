local FlyTextHelper = T(Lib, "FlyTextHelper")
local Entity = _ENV.Entity

function Entity:showHurtEffect(part, hurt, objID)
  if Me.objID == objID then
    self:showHurtUIEffect(hurt)
    return
  end
  if hurt <= 0 then
    return
  end
  local scale = 2.5
  local flytextInterval = World.cfg.BloodTipsSetting.tipsTime
  self.periodHurt = (self.periodHurt or 0) + hurt
  if flytextInterval then
    local now = World.CurWorld:getTickCount()
    if now >= (self.nextHurtTextTime or 0) then
      Plugins.CallTargetPluginFunc("fly_text", "flySceneBlood", part, 2, self.periodHurt, scale)
      self.periodHurt = 0
      self.nextHurtTextTime = now + flytextInterval
    end
  else
    FlyTextHelper:onShowEntityFlyText(part, 2, self.periodHurt, scale)
  end
end

function Entity:showHurtUIEffect(hurt)
  self.periodHurt = (self.periodHurt or 0) + hurt
  local now = World.CurWorld:getTickCount()
  if now >= (self.nextHurtTextTime or 0) then
    Plugins.CallTargetPluginFunc("fly_text", "flyUIBlood", self.periodHurt)
    self.nextHurtTextTime = now + World.cfg.BloodTipsSetting.tipsTime
    self.periodHurt = 0
  end
end

function Entity:getAreaID()
  local reportArea = World.cfg.reportArea
  local pos = self:getPosition()
  for i, v in ipairs(reportArea) do
    if pos.x >= v.x[1] and pos.x <= v.x[2] and pos.y >= v.y[1] and pos.y <= v.y[2] and pos.z >= v.z[1] and pos.z <= v.z[2] then
      return v.id
    end
  end
  return -1
end

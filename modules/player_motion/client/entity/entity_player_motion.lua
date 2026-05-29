local PlayerMotionConfig = T(Config, "PlayerMotionConfig")
local EntityMotionClient = Entity
local DefaultActionMapping = {
  idle = "idle",
  run = "run",
  sneak = "sneak",
  walk = "walk",
  jump2 = "jump2",
  jump_fall = "jump_fall",
  jump3 = "jump3"
}

function EntityMotionClient:pam_updateMotion()
  if not self.isPlayer then
    return
  end
  local motionId = self:pam_getMotionID()
  if self.lastMotionID == motionId or not self.lastMotionID and motionId == 0 then
    return
  end
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_PAM_MOTION_CHANGED)
  end
  self.lastMotionID = motionId
  local config = PlayerMotionConfig:getCfgById(motionId)
  if not config then
    self:pam_stopMotion()
    return
  end
  self:pam_playMotion(config)
end

function EntityMotionClient:pam_playMotion(param)
  local action = param.actionKey
  for key, value in pairs(DefaultActionMapping) do
    self:setActionMapping(key, action)
  end
  self.isPlayEntityMotionTick = World.CurWorld:getTickCount()
end

function EntityMotionClient:pam_stopMotion()
  for key, value in pairs(DefaultActionMapping) do
    self:setActionMapping(key, value)
  end
end

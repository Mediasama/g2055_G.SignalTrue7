local PlayerMotionConfig = T(Config, "PlayerMotionConfig")
local DefaultMotionSkinData = {gun = ""}
local PlayerMotionServer = Player

function PlayerMotionServer:pam_playMotion(id)
  local state = self:getCurState()
  if state ~= Define.CHARACTER_STATE_TYPE.NORMAL then
    return
  end
  local config = PlayerMotionConfig:getCfgById(id)
  if not config then
    return
  end
  self:resetDefaultWeapon(true)
  self:changeSkin(config.skinData)
  self:pam_setMotionID(id)
  self.motionStartTime = os.time()
end

function PlayerMotionServer:pam_stopMotion()
  local currentMotionID = self:pam_getMotionID()
  if currentMotionID == 0 then
    return
  end
  self:changeSkin(DefaultMotionSkinData)
  local reportData = {}
  reportData.action_id = currentMotionID
  reportData.action_time = os.time() - self.motionStartTime
  self:evt_reportEvent(Define.EventTracking.Type.UseAction, reportData, true)
  self:pam_setMotionID(0)
end

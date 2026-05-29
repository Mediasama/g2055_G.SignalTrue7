local GuideConfig = require("common.config.guide_config")
local Player = _ENV.Player

function Player:checkOutHome()
  local b = true
  if not self:isEndGuide() then
    local id = self:getGuideID()
    if id == Define.GUIDE_PUT_MONEY then
      self:saveGuideID(id + 1)
      self:sendPacket({
        pid = "finishGuide"
      })
    elseif self.guideLock then
      b = false
      local content = World.cfg.guildEnemy.lockDoorTips
      self:sendPacket({
        pid = "clientAddOneNewFlyTexts",
        content = content
      })
    end
  end
  return b
end

function Player:checkGuideLockDoor()
  if not self:isEndGuide() then
    self.guideLock = true
    local lastTick = World.cfg.guildEnemy.lockDoorTime * 20
    World.LightTimer("lastTick", lastTick, function()
      self.guideLock = false
    end)
  end
end

function Player:isEndGuide()
  if not self:isOpenGuide() then
    return true
  end
  local id = self:getGuideID() or -1
  local config = GuideConfig:getCfgById(id + 1)
  local b = true
  if config then
    b = false
  end
  return b
end

function Player:saveGuideID(id)
  self:setGuideID(id)
  local data = {guide_id = id}
  self:evt_reportEvent("guide_complete", data, true)
end

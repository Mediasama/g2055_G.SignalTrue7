local TimeDown = 3
local LuaTimer = T(Lib, "LuaTimer")

function M:onOpen(params)
  print("M:onOpen(params)", params)
  self:initUI(params or {})
  Lib.openDeathCamera(World.cfg.deathCameraCfg.time)
end

function M:closeWindow()
  Lib.resetDeathCamera()
  Lib.emitEvent(Event.EVENT_UI_CLOSE_DEAD)
end

function M:initUI(params)
  local text = Lang:getMessage("charter.killed.tips")
  local descString = string.format(text, params.who or "xx")
  self.descText:setText(descString)
  self:countDowning()
end

function M:countDowning()
  local count = World.cfg.deathCameraCfg.reliveTime
  local text = Lang:getMessage("charter.relive.tips")
  self.timeText:setText(string.format(text, count))
  self.downTimer = LuaTimer:scheduleTimer(function()
    count = count - 1
    self.timeText:setText(string.format(text, count))
    if 0 < count then
      return true
    end
    self:closeWindow()
    Me:sendPacket({
      pid = "RequestRevive"
    })
  end, 1000, World.cfg.deathCameraCfg.reliveTime)
end

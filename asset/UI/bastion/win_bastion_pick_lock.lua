local WinBastionPickLock = M

function WinBastionPickLock:initUI()
  self.btnClose = self:child("ButtonClose")
  self.validArea = self:child("ValidArea")
  self.cursor = self:child("Cursor")
  self.wrongMark = self:child("WrongMark")
  self.rightMark = self:child("RightMark")
  self.trigger = self:child("Trigger")
  self.progressBar = self:child("ProgressBar")
end

function WinBastionPickLock:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:cancelHack()
    self:close()
  end
  
  function self.trigger.onMouseClick()
    self:tryPick()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:cancelHack()
    self:close()
  end)
end

function WinBastionPickLock:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  local doorConfig = self.info.doorConfig
  local gearSize = 540 / doorConfig.totalGearCount
  self.moveSpeed = doorConfig.cursorSpeed
  self.penaltyTime = doorConfig.penaltyTime
  self.rangeLeft = 0
  self.rangeRight = doorConfig.totalGearCount * gearSize
  self.validSize = doorConfig.greenGearCount * gearSize
  local randomSize = self.rangeRight - self.rangeLeft - self.validSize
  self.validLeft = math.random(0, randomSize)
  self.validRight = self.validLeft + self.validSize
  local size = self.validArea:getSize()
  size.width[2] = self.validSize
  self.validArea:setSize(size)
  local position = Lib.copy(self.validArea:getPosition())
  position[1][2] = self.validLeft
  self.validArea:setPosition(position)
  self:setStatus("Normal")
  self.updateSchedule = Lib.subscribeEvent(Event.EVENT_RENDER_TICK, function(frameTime)
    self:updateCursor(frameTime)
    self:updateProgress(frameTime)
  end)
end

function WinBastionPickLock:getStatus()
  return self.status
end

function WinBastionPickLock:setStatus(status)
  if status == "Normal" then
    self.pauseTime = 0
    self.status = status
    self.wrongMark:setVisible(false)
    self.rightMark:setVisible(false)
  elseif status == "Wrong" then
    self.pauseTime = self.penaltyTime
    self.status = status
    self.wrongMark:setVisible(true)
    self.rightMark:setVisible(false)
  elseif status == "Right" then
    self.status = status
    self.wrongMark:setVisible(false)
    self.rightMark:setVisible(true)
  end
end

function WinBastionPickLock:tryPick()
  local status = self:getStatus()
  if status ~= "Normal" then
    return
  end
  local position = self.cursor:getPosition()
  local cursorPos = position[1][2]
  if cursorPos >= self.validLeft and cursorPos <= self.validRight then
    self:setStatus("Right")
    self:confirmHack()
  else
    self:setStatus("Wrong")
  end
end

function WinBastionPickLock:cancelHack()
  local param = {type = "cancel"}
  Me:C2S_RequestHackDoor(param)
end

function WinBastionPickLock:confirmHack()
  local param = {type = "confirm"}
  Me:C2S_RequestHackDoor(param)
end

function WinBastionPickLock:updateCursor(frameTime)
  if self.status == "Normal" then
    local position = self.cursor:getPosition()
    local newPosition = Lib.copy(position)
    local x = position[1][2] + self.moveSpeed * frameTime
    if self.moveSpeed > 0 then
      if x > self.rangeRight then
        x = self.rangeRight * 2 - x
        self.moveSpeed = self.moveSpeed * -1
      end
    elseif self.moveSpeed < 0 and x < self.rangeLeft then
      x = self.rangeLeft * 2 - x
      self.moveSpeed = self.moveSpeed * -1
    end
    newPosition[1][2] = x
    self.cursor:setPosition(newPosition)
  elseif self.status == "Wrong" then
    self.pauseTime = math.max(0, self.pauseTime - frameTime)
    if 0 >= self.pauseTime then
      self:setStatus("Normal")
    end
  end
end

function WinBastionPickLock:updateProgress(frameTime)
  local hackInfo = self.info.hackInfo
  local startTime = hackInfo.startTime
  local endTime = hackInfo.endTime
  local currentTime = os.time()
  local percentage = 1 - math.min(math.max(0, (currentTime - startTime) / (endTime - startTime)), 1)
  self.progressBar:setVisible(true)
  self.progressBar:setProgress(percentage)
end

function WinBastionPickLock:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionPickLock:onClose()
  if self.updateSchedule then
    self.updateSchedule()
    self.updateSchedule = nil
  end
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
end

return WinBastionPickLock

function M:onOpen(params)
  Me:sendPacket({
    pid = "getMatchData"
  })
  self:initUI(params or {})
  self.noTimer = true
end

function M:initUI(params)
  Lib.subscribeEvent(Event.EVENT_MATCH_DATA, function(data)
    self:updateView(data)
  end)
  
  function self.Image.closeButton.onMouseClick()
    if self.leftTimer then
      self.leftTimer()
      self.leftTimer = nil
    end
    Lib.closeWindow("UI/battle_match")
  end
  
  function self.Image.JoinButton.onMouseClick()
    if self.leftTimer then
      self.leftTimer()
      self.leftTimer = nil
    end
    Lib.closeWindow("UI/battle_match")
  end
end

function M:updateView(data)
  if not self.Image then
    return
  end
  if not self.Image.manCountText then
    return
  end
  self.Image.manCountText:setText(data.totalCount)
  self.Image.totalTimeText:setText(data.totalTime)
  if data.totalCount == 0 then
    self.Image.leftTimeText:setVisible(false)
    self.Image.joinText:setVisible(false)
    self.Image.JoinButton:setVisible(true)
  else
    self.Image.leftTimeText:setVisible(false)
    self.Image.joinText:setVisible(false)
    self.Image.JoinButton:setVisible(true)
    self:countDowning(data.totalTime)
  end
end

function M:countDowning(time)
  local count = math.ceil(time)
  local text = "%s\231\167\146"
  self.Image.totalTimeText:setText(string.format(text, count))
  if self.noTimer then
    self.leftTimer = World.LightTimer("", 20, function()
      count = count - 1
      if not self.Image then
        return
      end
      self.Image.totalTimeText:setText(string.format(text, count))
      if 0 < count then
        self.noTimer = false
        return true
      end
      self.noTimer = true
      Lib.closeWindow("UI/battle_match")
    end)
  end
end

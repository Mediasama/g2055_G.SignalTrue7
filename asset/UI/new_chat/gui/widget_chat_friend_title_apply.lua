function M:init()
  self._allEvent = {}
  
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imageBG = self.ImageBG
  self.textTitle = self.ImageBG.TextTitle
  self.textTitle:setText(Lang:toText("new.chat.friend.applyFriend"))
  self.imageRedDot = self.ImageBG.ImageRedDot
  self.textCount = self.ImageBG.ImageRedDot.TextCount
end

function M:initEvent()
  function self.imageBG.onWindowTouchDown()
    Lib.emitEvent(Event.EVENT_CHAT_ENTER_FRIEND_APPLY)
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_FRIEND_APPLY_RED_DOT, function(num)
    self:updateApplyRedNum(num)
  end)
end

function M:updateApplyRedNum(num)
  self.imageRedDot:setVisible(0 < num)
  if 0 < num then
    self.textCount:setText(tostring(99 < num and "99+" or num))
  end
end

function M:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

M:init()

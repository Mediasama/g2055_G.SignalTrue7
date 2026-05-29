function M:init()
  self._allEvent = {}
  
  self.data = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imageBG = self:child("ImageBG")
  self.textDetail = self:child("TextDetail")
  self.textReward = self:child("TextReward")
  self.textLimit = self:child("TextLimit")
end

function M:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_WIN_CLOSE, function()
    self:onClose()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_QUEST_UPDATE, function(value)
    self:updateQuestProgress(self.data)
  end)
end

function M:initData(data)
  if not data then
    return
  end
  self.data = data
  self.textDetail:setText(Lang:toText({
    data.detail,
    data.target_num
  }))
  self.textReward:setText(data.exp .. "Exp")
  self.imageBG:setVisible(data.id % 2 == 0)
  self.textProgressTest = self:child("TextProgressTest")
  self:updateQuestProgress(data)
end

function M:updateQuestProgress(data)
  if not data then
    return
  end
  if data.day_limit < 0 then
    self.textLimit:setText("-")
  else
    local questItem = Me:getPlayerPassCardQuestItem(data.id)
    if questItem then
      self.textLimit:setText(questItem.sumExp .. "/" .. data.day_limit)
      if self.textProgressTest then
        self.textProgressTest:setText(questItem.progress .. "/" .. data.target_num)
      end
    end
  end
end

function M:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

M:init()

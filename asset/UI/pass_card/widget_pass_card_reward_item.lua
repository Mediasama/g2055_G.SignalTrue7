function M:init()
  self._allEvent = {}
  
  self.data = nil
  self.reward = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imageGold = self:child("ImageGold")
  self.imageFree = self:child("ImageFree")
  self.textLevel = self:child("TextLevel")
  self.imageMask = self:child("ImageMask")
  self.imageLock = self:child("ImageLock")
  self.imageIcon = self:child("ImageIcon")
  self.textNum = self:child("TextNum")
  self.imageGet = self:child("ImageGet")
  self.imageCenter = self:child("ImageCenter")
  self.imageRect = self:child("ImageRect")
end

function M:initEvent()
  function self.imageMask.onMouseClick()
    if self.data then
      self:openDetailWin()
    end
  end
  
  function self.imageCenter.onMouseClick()
    if self.data then
      if not Me:playerGotPassCardReward(self.data.isGold, self.data.passCardData.level) then
        self:getReward()
      else
        self:openDetailWin()
      end
    end
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_WIN_CLOSE, function()
    self:onClose()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_LEVEL_UP, function(value)
    self:updateUIMask()
    self:updateUIGetReward()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_BUY_GOLD_CARD, function(value)
    self:updateUIMask()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_GET_REWARD, function(value)
    self:updateUIGetReward()
  end)
end

function M:initData(data)
  if not data or not data.passCardData then
    return
  end
  self.data = data
  local passCardData = data.passCardData
  local reward = data.isGold and passCardData.reward_gold or passCardData.reward_free
  self.reward = reward
  if data.isGold then
    self.imageGold:setVisible(true)
    self.imageFree:setVisible(false)
    self.textLevel:setVisible(false)
    self:child("TextLevel"):setText(passCardData.level)
    self.imageIcon:setImage(passCardData.icon_gold)
  else
    self.imageGold:setVisible(false)
    self.imageFree:setVisible(true)
    self.textLevel:setVisible(true)
    self.textLevel:setText(passCardData.level)
    self.imageIcon:setImage(passCardData.icon_free)
  end
  if reward.num > 0 then
    self.textNum:setText(reward.num)
  else
    self.textNum:setText("")
  end
  self:updateUIMask()
  self:updateUIGetReward()
end

function M:updateUIMask()
  if not self.data then
    return
  end
  local playerPassCard = Me:getPlayerPassCard()
  if playerPassCard then
    local hideMask = false
    if self.data.passCardData.level <= playerPassCard.level then
      hideMask = not self.data.isGold or playerPassCard.hasGoldCard
    end
    self.imageMask:setVisible(not hideMask)
    self.imageLock:setVisible(not hideMask)
  end
end

function M:updateUIGetReward()
  if not self.data then
    return
  end
  local playerPassCard = Me:getPlayerPassCard()
  if playerPassCard then
    self.imageGet:setVisible(Me:playerGotPassCardReward(self.data.isGold, self.data.passCardData.level))
    self.imageRect:setVisible(Me:playerCanGetPassCardReward(self.data.isGold, self.data.passCardData.level))
  end
end

function M:getReward()
  if not self.data then
    return
  end
  local isGold = self.data.isGold
  local level = self.data.passCardData.level
  Me:sendPacket({
    pid = "passCardGetRewardC2S",
    isGold = isGold,
    level = level
  }, function(isSuccess, result)
    if isSuccess and 0 < result then
      local dialogBox = Lib.openWindow("./UI/pass_card/win_pass_card_dialog_box")
      if dialogBox then
        dialogBox:setDetail(Lang:toText(Define.PassCardGetRewardRespondText[result]))
        dialogBox:setCallBack(self, self.getRewardSure, result)
      end
    end
  end)
end

function M:getRewardSure(result)
  if not self.data then
    return
  end
  local isGold = self.data.isGold
  local level = self.data.passCardData.level
  Me:sendPacket({
    pid = "passCardGetRewardSureC2S",
    isGold = isGold,
    level = level
  }, function(isSuccess)
    if isSuccess and (result == Define.PassCardGetRewardRespond.ToCarShop or result == Define.PassCardGetRewardRespond.GetOffToCarShop) then
      Plugins.CallTargetPluginFunc("pass_card", "closePassCardWin")
    end
  end)
end

function M:openDetailWin()
  local win = Lib.openWindow("./UI/pass_card/win_pass_card_item_detail")
  if win then
    local passCardData = self.data.passCardData
    local reward = self.data.isGold and passCardData.reward_gold or passCardData.reward_free
    win:setItemId(reward.id)
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

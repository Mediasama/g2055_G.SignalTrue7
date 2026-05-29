local PassCardConfig = T(Config, "PassCardConfig")

function M:init()
  self._allEvent = {}
  self.data = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.panel = self:child("Panel")
  self.buttonBuy = self:child("ButtonBuy")
  self.textPrice = self:child("TextPrice")
end

function M:initEvent()
  function self.buttonBuy.onMouseClick()
    self:openBuyCardLevelUpWin()
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_WIN_CLOSE, function()
    self:onClose()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_LEVEL_UP, function(value)
    self:updateUI()
  end)
end

function M:initData(data)
  if not data or not data.passCardData then
    return
  end
  self.data = data
  self:updateUI()
end

function M:updateUI()
  if not self.data then
    return
  end
  local playerPassCardData = Me:getPlayerPassCard()
  local passCardData = self.data.passCardData
  local playerPassCard = Me:getPlayerPassCard()
  local showButton = passCardData.level == playerPassCard.level and not Me:playerPassCardMaxLevel()
  self.buttonBuy:setVisible(showButton)
  if showButton then
    self.textPrice:setText(passCardData.price)
  end
  self.panel:setVisible(passCardData.level <= playerPassCard.level)
end

function M:openBuyCardLevelUpWin()
  if Me:playerPassCardMaxLevel() then
    return
  end
  local dialogBox = Lib.openWindow("./UI/pass_card/win_pass_card_dialog_box")
  if dialogBox then
    dialogBox:setDetail(Lang:toText({
      "passCard.buyLevel",
      self.data.passCardData.price
    }))
    dialogBox:setCallBack(self, self.buyLevel)
  end
end

function M:buyLevel()
  local cost = self.data.passCardData.price
  local wallet = Me:data("wallet")
  if wallet and wallet.gDiamonds and cost <= wallet.gDiamonds.count then
    Me:sendPacket({
      pid = "buyPassCardLevelUpC2S",
      level = self.data.passCardData.level
    })
  else
    Interface.onRecharge(1)
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

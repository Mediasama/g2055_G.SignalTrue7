local widget_virtual_horz_list = require("ui.widget.widget_virtual_horz_list")
local widget_virtual_vert_list = require("ui.widget.widget_virtual_vert_list")
local PassCardConfig = T(Config, "PassCardConfig")
local PassCardQuestConfig = T(Config, "PassCardQuestConfig")
M.TAB_TYPE = {TAB_REWARD = 1, TAB_QUEST = 2}

function M:init()
  self._allEvent = {}
  self.tabList = {}
  self.panelList = {}
  self.virtualLists = {}
  self.beginDateStr = World.cfg.passCardBeginDate
  self.endDateStr = World.cfg.passCardEndDate
  self.goldCardPrice = World.cfg.goldPassCardPrice or 30
  self:initUI()
  self:initEvent()
  self:initData()
  self:selectTab(M.TAB_TYPE.TAB_REWARD)
  World.Timer(1, function()
    self:resetScrollPos()
  end)
end

function M:initUI()
  self.btnClose = self:child("ButtonClose")
  self.buttonBuyGoldCard = self:child("ButtonBuyGoldCard")
  self.expBar = self:child("ProgressBar")
  self.textCurLevel = self:child("TextCurLevel")
  self.textNextLevel = self:child("TextNextLevel")
  self.textExp = self:child("TextExp")
  self:child("TextTitle"):setText(Lang:toText("passCard.title"))
  self:child("TextGoldCardPrice"):setText(self.goldCardPrice)
  self:child("TextDescribe"):setText(Lang:toText("passCard.taskDetails"))
  self:child("TextReward"):setText(Lang:toText("passCard.taskRewards"))
  self:child("TextLimit"):setText(Lang:toText("passCard.taskDailyLimit"))
  if self.beginDateStr and self.endDateStr then
    self:child("TextDate"):setText("[colour='FFFFFFFF']" .. self.beginDateStr .. "-[colour='FFFF0000']" .. self.endDateStr)
  end
  self:updateLevelUI()
  self:updateGoldCardUI()
  self.scrollViewWidth = self:child("PanelRight"):getPixelSize().width
  self.tabList[M.TAB_TYPE.TAB_REWARD] = self:child("PanelTabReward")
  self.tabList[M.TAB_TYPE.TAB_QUEST] = self:child("PanelTabQuest")
  self.panelList[M.TAB_TYPE.TAB_REWARD] = self:child("PanelReward")
  self.panelList[M.TAB_TYPE.TAB_QUEST] = self:child("PanelQuest")
  local scrollView = self:child("ScrollableViewQuest")
  self.questVirtualList = widget_virtual_vert_list:init(scrollView, scrollView.VerticalLayout, function(self, parentWindow)
    local item = UI:openWidget("./UI/pass_card/widget_pass_card_quest_item")
    parentWindow:addChild(item:getWindow())
    return item
  end, function(self, childWindow, data)
    childWindow:initData(data)
  end)
  local scrollViewCard = self:child("ScrollableViewCard")
  self.rewardVirtualList = widget_virtual_horz_list:init(scrollViewCard, scrollViewCard.HorizontalLayout, function(self, parentWindow)
    local item = UI:openWidget("./UI/pass_card/widget_pass_card_reward_rect")
    parentWindow:addChild(item:getWindow())
    if M.itemWidth == nil then
      M.itemWidth = item:getPixelSize().width
    end
    return item
  end, function(self, childWindow, data)
    childWindow:initData(data)
  end)
end

function M:initData()
  local allReward = PassCardConfig:getAllCfgs()
  for i = 1, #allReward do
    self.rewardVirtualList:addVirtualChild(allReward[i])
  end
  self.scrollDataWidth = self.rewardVirtualList:getVirtualSize()[1]
  local allQuest = PassCardQuestConfig:getAllCfgs()
  for i = 1, #allQuest do
    local quest = allQuest[i]
    if quest.is_active == 1 then
      self.questVirtualList:addVirtualChild(quest)
    end
  end
end

function M:initEvent()
  function self.btnClose.onMouseClick()
    self:close()
  end
  
  function self.buttonBuyGoldCard.onMouseClick()
    Lib.emitEvent(Event.EVENT_PASS_CARD_UNLOCK)
  end
  
  for i = 1, #self.tabList do
    self.tabList[i].onMouseButtonDown = function()
      self:selectTab(i)
    end
  end
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_LEVEL_UP, function(value)
    self:updateLevelUI()
    self:resetScrollPos()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_ADD_EXP, function(value)
    self:updateLevelUI()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_BUY_GOLD_CARD, function(value)
    self:updateGoldCardUI()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PASS_CARD_UNLOCK, function(value)
    self:openBuyGoldCardWin()
  end)
end

function M:selectTab(tabType)
  if self.tabList[tabType] and self.panelList[tabType] then
    for i = 1, #self.tabList do
      self.tabList[i].ImageSelect:setVisible(i == tabType)
      self.tabList[i].ImageUnselected:setVisible(i ~= tabType)
      self.panelList[i]:setVisible(i == tabType)
    end
  end
end

function M:updateLevelUI()
  local passCard = Me:getPlayerPassCard()
  if passCard then
    local isMaxLevel = Me:playerPassCardMaxLevel()
    if isMaxLevel then
      self.textCurLevel:setText("MAX")
      self.textNextLevel:setText("MAX")
      self.expBar:setProgress(1)
      self.textExp:setVisible(false)
    else
      local cfg = PassCardConfig:getCfgById(passCard.level)
      if cfg and cfg.exp and cfg.exp > 0 then
        self.textCurLevel:setText("LV." .. passCard.level)
        self.textNextLevel:setText("LV." .. passCard.level + 1)
        self.expBar:setProgress(passCard.exp / cfg.exp)
        self.textExp:setVisible(true)
        self.textExp:setText(passCard.exp .. "/" .. cfg.exp)
      end
    end
  end
end

function M:updateGoldCardUI()
  local playerPassCard = Me:getPlayerPassCard()
  self.buttonBuyGoldCard:setVisible(not playerPassCard.hasGoldCard)
end

function M:openBuyGoldCardWin()
  local dialogBox = Lib.openWindow("./UI/pass_card/win_pass_card_dialog_box")
  if dialogBox then
    dialogBox:setDetail(Lang:toText({
      "passCard.buyPassport",
      self.goldCardPrice
    }))
    dialogBox:setCallBack(self, self.buyPassGoldCard)
  end
end

function M:buyPassGoldCard()
  local cost = self.goldCardPrice
  local wallet = Me:data("wallet")
  if wallet and wallet.gDiamonds and cost <= wallet.gDiamonds.count then
    Me:sendPacket({
      pid = "buyPassGoldCardC2S"
    })
  else
    Interface.onRecharge(1)
  end
end

function M:resetScrollPos()
  if not (self.itemWidth and self.scrollDataWidth) or not self.scrollViewWidth then
    return
  end
  local playerPassCard = Me:getPlayerPassCard()
  if playerPassCard and playerPassCard.level then
    local offset = math.max(0, (playerPassCard.level + 1) * self.itemWidth - self.scrollViewWidth)
    local totalScrollRange = math.max(0, self.scrollDataWidth - self.scrollViewWidth)
    local scrollPos = totalScrollRange == 0 and 0 or offset / totalScrollRange
    self.rewardVirtualList:getWindow():setProperty("HorzScrollPosition", scrollPos)
  end
end

function M:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Lib.emitEvent(Event.EVENT_PASS_CARD_WIN_CLOSE)
end

M:init()

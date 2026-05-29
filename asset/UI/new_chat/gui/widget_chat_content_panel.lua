local widget_virtual_vert_list = require("ui.widget.widget_virtual_vert_list")
local ChatHelper = T(World, "ChatHelper")
local ChatUIHelper = T(World, "ChatUIHelper")

function M:init()
  self._allEvent = {}
  self.newMsgCounter = 0
  self.chatPage = nil
  self.privateChatTarget = nil
end

function M:initUI()
  self.layoutMsgList = self.ScrollableView.VerticalLayoutMsgList
  self.panelNewMsg = self.PanelNewMsg
  self.buttonNewMsg = self.PanelNewMsg.ButtonNewMsg
  self.messageView = widget_virtual_vert_list:init(self.ScrollableView, self.layoutMsgList, function(self, parentWindow)
    local item = UI:openWidget(ChatUIHelper:getContentItemType(M.chatPage))
    parentWindow:addChild(item:getWindow())
    return item
  end, function(self, childWindow, msg)
    childWindow:initData(msg)
  end)
end

function M:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PUSH_CHAT_MSG, function(msgData)
    if self:isMyMsg(msgData) then
      Lib.logInfo(">>>>>>>>>> receive msg:", msgData.fromId, msgData.msg)
      local atBottomNow = self.messageView:getWindow():getProperty("VertScrollPosition") == tostring(1)
      local isFull = self:isScrollPanelFull()
      if self.messageView:getVirtualChildCount() >= World.cfg.chatSetting.pageMsgMaxCount then
        self.messageView:delVirtualChild(1)
      end
      self.messageView:addVirtualChild(msgData)
      if not atBottomNow and isFull then
        self:setNewMsgTipsVisible(true)
        self.newMsgCounter = self.newMsgCounter + 1
        self.buttonNewMsg:setText(Lang:toText({
          "new_chat_new_msg_tips",
          self.newMsgCounter > 99 and "99+" or self.newMsgCounter
        }))
      else
        World.Timer(1, function()
          self.messageView:getWindow():setProperty("VertScrollPosition", 1)
        end)
      end
    end
  end)
  
  function self.buttonNewMsg.onMouseClick()
    self.messageView:getWindow():setProperty("VertScrollPosition", 1)
    self:setNewMsgTipsVisible(false)
  end
  
  function self.ScrollableView.onScrolled()
    local atBottomNow = self.messageView:getWindow():getProperty("VertScrollPosition") == tostring(1)
    if atBottomNow then
      self:setNewMsgTipsVisible(false)
    end
  end
end

function M:initData()
  local msgList = ChatHelper:getPageMsgList(self.chatPage, self.privateChatTarget)
  print("content panel init ,all msg num:==========>>", self.chatPage, self.privateChatTarget, msgList and #msgList or "no msg list")
  for _, v in ipairs(msgList) do
    self.messageView:addVirtualChild(v)
  end
  World.Timer(1, function()
    self.messageView:getWindow():setProperty("VertScrollPosition", 1)
  end)
  self:setNewMsgTipsVisible(false)
end

function M:clearData()
  self.messageView:clearVirtualChild()
end

function M:initOnEnter()
  if self.messageView and not self.buttonNewMsg:isVisible() then
    World.Timer(1, function()
      self.messageView:getWindow():setProperty("VertScrollPosition", 1)
    end)
    self:setNewMsgTipsVisible(false)
  end
end

function M:delayInit(chatPage, privateChatTarget)
  self.chatPage = chatPage
  self.privateChatTarget = privateChatTarget
  self:initUI()
  self:initEvent()
end

function M:setNewMsgTipsVisible(visible)
  self.buttonNewMsg:setVisible(visible)
  if not visible then
    self.newMsgCounter = 0
  end
end

function M:isScrollPanelFull()
  local view = self.ScrollableView:getWindow():getViewableArea()
  local viewHeight = view.bottom - view.top
  local paneHeight = self.ScrollableView:getVirtualSize()[2]
  return viewHeight <= paneHeight
end

function M:stopVoiceDataPlaying()
end

function M:isMyMsg(msgData)
  if msgData and self.chatPage == msgData.pageType then
    if msgData.msgType == Define.ChatPage.Private then
      return msgData.keyId == self.privateChatTarget
    else
      return true
    end
  end
  return false
end

function M:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.messageView then
    self.messageView:clearVirtualChild()
  end
end

M:init()

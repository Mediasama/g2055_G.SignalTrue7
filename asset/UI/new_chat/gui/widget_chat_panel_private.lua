local ChatHelper = T(World, "ChatHelper")
local widget_virtual_vert_list = require("ui.widget.widget_virtual_vert_list")
M.PanelState = {History = 1, PrivateChat = 2}

function M:init()
  self.delayInited = false
  self.panelState = nil
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
    if tab == Define.ChatPage.Private then
      self:delayInit()
      self:initOnEnter()
    end
  end)
end

function M:initUI()
  self.contentPanel = nil
  self.PanelHistory.PanelTop.TextTitle:setText(Lang:toText("new.chat.recent.private.chat"))
  self.textPlayerName = self.PanelChat.PanelTop.TextPlayerName
  self.panelBack = self.PanelChat.PanelTop.PanelBack
  self.scrollView = self.PanelHistory.PanelChatContent.ScrollableView
  self.verticalLayoutHistory = self.scrollView.VerticalLayout
  self.historyItemView = widget_virtual_vert_list:init(self.scrollView, self.verticalLayoutHistory, function(self, parentWindow)
    local item = UI:openWidget("./UI/new_chat/gui/widget_chat_private_history_item")
    parentWindow:addChild(item:getWindow())
    return item
  end, function(self, childWindow, msg)
    childWindow:initData(msg)
  end)
end

function M:initEvent()
  function self.panelBack.onMouseClick()
    self:setPanelState(M.PanelState.History)
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET, function(id)
    print("panel_private receive EVENT_CHAT_SET_CUR_CHAT_TARGET,target_id ", id)
    self:setPanelState(M.PanelState.PrivateChat, id)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PUSH_CHAT_MSG, function(msgData)
    print("panel private receive EVENT_PUSH_CHAT_MSG,msgData.pageType,self.chatPage:", msgData.pageType, msgData.keyId, self.contentPanel and self.contentPanel.privateChatTarget or nil, self.panelState)
    if msgData.pageType == Define.ChatPage.Private and self.panelState == M.PanelState.PrivateChat and self.contentPanel.privateChatTarget == msgData.keyId then
      print(">>>>>>>>>> panel private receive EVENT_PUSH_CHAT_MSG,clear msg counter")
      ChatHelper:clearNewMsgCounter(msgData.pageType, msgData.keyId)
    end
  end)
end

function M:delayInit()
  if not self.delayInited then
    self:initUI()
    self:initEvent()
    self:setPanelState(M.PanelState.History)
    self.delayInited = true
  end
end

function M:setPanelState(state, privateChatTarget)
  self.panelState = state
  self.PanelHistory:setVisible(state == M.PanelState.History)
  self.PanelChat:setVisible(state == M.PanelState.PrivateChat)
  local winMain = UI:isOpenWindow("./UI/new_chat/gui/win_chat_main")
  if state == M.PanelState.History then
    winMain:setInputVisible(false)
    self.historyItemView:clearVirtualChild()
    local msgListGroup = ChatHelper:getPageMsgListGroup(Define.ChatPage.Private)
    for k, v in pairs(msgListGroup) do
      local msg = ChatHelper:getLatestMsg(Define.ChatPage.Private, k)
      if msg and next(msg) then
        self.historyItemView:addVirtualChild(msg[1])
      end
    end
  else
    winMain:setInputVisible(true)
    local detailInf = ChatHelper:getUserDetailInfo(privateChatTarget)
    if detailInf then
      self.textPlayerName:setText(detailInf.nickName)
    end
    if not self.contentPanel then
      self.contentPanel = UI:openWidget("./UI/new_chat/gui/widget_chat_content_panel")
      self.contentPanel:delayInit(Define.ChatPage.Private, privateChatTarget)
      self.contentPanel:initData()
      self.PanelChat.PanelChatContent:addChild(self.contentPanel)
    elseif self.contentPanel.privateChatTarget ~= privateChatTarget then
      self.contentPanel.privateChatTarget = privateChatTarget
      self.contentPanel:clearData()
      self.contentPanel:initData()
    end
  end
  self:initOnEnter()
end

function M:initOnEnter()
  if self.contentPanel and self.panelState == M.PanelState.PrivateChat then
    self.contentPanel:initOnEnter()
  end
end

function M:canShowInputPanel()
  return self.panelState == M.PanelState.PrivateChat
end

function M:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.historyItemView then
    self.historyItemView:clearVirtualChild()
  end
end

M:init()

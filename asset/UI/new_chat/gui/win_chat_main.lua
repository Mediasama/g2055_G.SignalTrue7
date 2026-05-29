local ChatHelper = T(World, "ChatHelper")

function M:init()
  self.curTab = nil
  self.privateChatTarget = nil
  self.panelList = {}
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_TAB, Define.ChatPage.World)
  AsyncProcess.LoadUserRequests()
  ChatHelper:requestPlayerOnlineState()
end

function M:initUI()
  self.PanelInput:addChild(UI:openWidget("./UI/new_chat/gui/widget_chat_input_panel"))
  self.tabList = self.PanelTab.VerticalLayoutTabList
  self.panelChat = self.PanelChat
  for _, v in ipairs(World.cfg.chatSetting.tabConfig) do
    if ChatHelper:checkShowTab(v.chatPage) then
      local tabItem = UI:openWidget(v.tabWidget)
      tabItem:initTab(v)
      self.tabList:addChild(tabItem)
      local panel = UI:openWidget(v.layout)
      panel:setVisible(false)
      self.panelList[v.chatPage] = panel
      self.panelChat:addChild(panel)
    end
  end
end

function M:initEvent()
  function self.PanelClose.onMouseClick()
    self:close()
    
    Lib.emitEvent(Event.EVENT_UI_OPEN_CHAT_MINI)
  end
  
  function self.Button.onMouseClick()
    self:test()
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
    self:onSetTab(tab)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET, function(id)
    self.privateChatTarget = id
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_FINISH_PARSE_REQUESTS_DATA, function()
    local num = 0
    local requests = FriendManager.requests
    for _, data in pairs(requests) do
      num = num + 1
    end
    Lib.emitEvent(Event.EVENT_UPDATE_FRIEND_APPLY_RED_DOT, num)
  end)
end

function M:onSetTab(tab)
  if self.curTab == tab then
    return
  end
  if self.panelList[self.curTab] then
    self.panelList[self.curTab]:setVisible(false)
  end
  self.panelList[tab]:setVisible(true)
  self.curTab = tab
  local showInput = self.panelList[tab]:canShowInputPanel()
  self:setInputVisible(showInput)
end

function M:stopVoiceDataPlaying(list)
  if not list then
    return
  end
  for _, v in pairs(list) do
    if v.msgType == Define.MsgType.Voice then
      v.isPlaying = false
    end
  end
end

function M:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopVoiceDataPlaying(ChatHelper:getPageMsgList(Define.ChatPage.World))
  Lib.emitEvent(Event.EVENT_CHAT_MAIN_CLOSE)
end

function M:setInputVisible(show)
  self.PanelInput:setVisible(show)
end

function M:test()
end

M:init()

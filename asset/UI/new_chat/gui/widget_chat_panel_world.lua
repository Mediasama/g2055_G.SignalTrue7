function M:init()
  self.delayInited = false
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
    if tab == Define.ChatPage.World then
      self:delayInit()
      self:initOnEnter()
    end
  end)
end

function M:initUI()
  self.contentPanel = UI:openWidget("./UI/new_chat/gui/widget_chat_content_panel")
  self.contentPanel:delayInit(Define.ChatPage.World)
  self.contentPanel:initData()
  self.PanelChatContent:addChild(self.contentPanel)
end

function M:initEvent()
end

function M:delayInit()
  if not self.delayInited then
    self:initUI()
    self:initEvent()
    self.delayInited = true
  end
end

function M:initOnEnter()
  if self.contentPanel then
    self.contentPanel:initOnEnter()
  end
end

function M:canShowInputPanel()
  return true
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

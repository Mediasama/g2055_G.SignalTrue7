local ChatHelper = T(World, "ChatHelper")
local ShortConfig = T(Config, "ShortConfig")
local chatSetting = World.cfg.chatSetting

function M:init()
  self.data = nil
  self.userDetailInfoCb = nil
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.widgetHead = UI:openWidget("./UI/new_chat/gui/widget_chat_player_head")
  self.widgetHead.hasAction = false
  self.PanelHead:addChild(self.widgetHead)
  self.imageRedDot = self.ImageRedDot
  self.textRedDotNum = self.ImageRedDot.TextCount
  self.textStatus = self.TextStatus
end

function M:initEvent()
  function self.onMouseClick()
    if self.data then
      Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET, self.data.keyId)
      
      ChatHelper:clearNewMsgCounter(self.data.pageType, self.data.keyId)
    end
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_UPDATE_RED_POINT, function(chatPage, keyId)
    if self.data then
      Lib.logInfo("history item receive EVENT_CHAT_UPDATE_RED_POINT,chatPage,self.chatPage,keyId:", chatPage, keyId, self.data.keyId)
      if chatPage == self.data.pageType and keyId == self.data.keyId then
        self:updateRedDot()
      end
    end
  end)
end

function M:initData(data)
  if data then
    self.data = data
    if self.data.sentTime then
      self.TextTime:setText(os.date("%H:%M", math.floor(self.data.sentTime / 1000)))
    end
    self.TextLastMsg:setText(self:getMsgText())
    local cfg = chatSetting.friendPanelCfg.onlineStatusColor
    local isOffline = ChatHelper:getChatPlayerOnlineState(self.data.keyId) == Define.onlineStatus.offline
    if isOffline then
      self.textStatus:setText(Lang:toText("new.chat.status.offline"))
      self.textStatus:setProperty("TextColours", cfg.offline or "FFFF0000")
    else
      self.textStatus:setText(Lang:toText("new.chat.status.online"))
      self.textStatus:setProperty("TextColours", cfg.online or "FF00FF00")
    end
    local detailInf = ChatHelper:getUserDetailInfo(self.data.keyId)
    if detailInf then
      self:cancelDetailListener()
      self:setDetailInf(detailInf)
    else
      self:listenDetailInfo(self.data.keyId)
    end
    self:updateRedDot()
  end
end

function M:setDetailInf(detailInf)
  if detailInf then
    self.TextName:setText(detailInf.nickName)
    self.widgetHead:initData(detailInf)
  end
end

function M:listenDetailInfo(userId)
  if not userId then
    Lib.logError("widget_chat_private_history_item:listenDetailInfo id is nil!")
    return
  end
  self:cancelDetailListener()
  self.userDetailInfoCancel = Lib.subscribeEvent("EVENT_USER_DETAIL" .. userId, function(data)
    self:setDetailInf(data)
  end)
  ChatHelper:initDetailInfo(userId)
end

function M:cancelDetailListener()
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
    self.userDetailInfoCancel = nil
  end
end

function M:getMsgText()
  local text = ""
  if self.data.msgType == Define.MsgType.Text then
    text = self.data.msg
  elseif self.data.msgType == Define.MsgType.ShortMsg then
    local shortMsgCfg = ShortConfig:getCfgById(tonumber(self.data.msg))
    if shortMsgCfg then
      text = shortMsgCfg.text
    end
  end
  return text
end

function M:updateRedDot()
  local num = ChatHelper:getNewMsgCounter(self.data.pageType, self.data.keyId)
  if 0 < num then
    self.textRedDotNum:setText(tostring(99 < num and "99+" or num))
    self.imageRedDot:setVisible(true)
  else
    self.imageRedDot:setVisible(false)
  end
end

function M:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:cancelDetailListener()
end

M:init()

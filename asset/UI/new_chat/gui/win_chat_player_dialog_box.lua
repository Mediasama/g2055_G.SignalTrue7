local ChatHelper = T(World, "ChatHelper")

function M:init()
  self.detailInf = nil
  self.isMyFriend = false
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.widgetHead = UI:openWidget("./UI/new_chat/gui/widget_chat_player_head")
  self.widgetHead.hasAction = false
  self.Panel.PanelPlayer.PanelHead:addChild(self.widgetHead)
  self.textPlayerName = self.Panel.PanelPlayer.TextName
  self.buttonFriend = self.Panel.ButtonFriend
  self.panelHeight = self.Panel:getHeight()[2]
  self.rootHeight = self:getPixelSize().height
  self:child("ButtonChat"):setText(Lang:toText("new_chat_private"))
  self:child("ButtonInvite"):setText(Lang:toText("new.chat.invite"))
end

function M:initEvent()
  function self.Panel.ButtonChat.onMouseClick()
    if self.detailInf then
      self:close()
      
      Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_TAB, Define.ChatPage.Private)
      Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET, self.detailInf.userId)
    end
  end
  
  function self.Panel.ButtonInvite.onMouseClick()
    if self.detailInf then
      self:sendInviteMsg(self.detailInf.userId)
      self:close()
    end
  end
  
  function self.buttonFriend.onMouseClick()
    if self.detailInf then
      if self.isMyFriend then
        AsyncProcess.FriendOperation(FriendManager.operationType.DELETE, self.detailInf.userId)
      else
        AsyncProcess.FriendOperation(FriendManager.operationType.ADD_FRIEND, self.detailInf.userId)
        Me:friendRequestReport(FriendManager.operationType.ADD_FRIEND, self.detailInf.userId, true)
      end
    end
    self:close()
  end
  
  function self.onWindowTouchDown()
    self:close()
  end
end

function M:initData(detailInf)
  if detailInf then
    self.detailInf = detailInf
    self.textPlayerName:setText(detailInf.nickName)
    self.widgetHead:initData(detailInf)
    self.isMyFriend = Me:checkPlayerIsMyFriend(detailInf.userId) ~= Define.friendStatus.notFriend
    self.buttonFriend:setVisible(true)
    if self.isMyFriend then
      self.buttonFriend:setText(Lang:toText("new.chat.player_delFriend"))
    else
      self.buttonFriend:setText(Lang:toText("new.chat.player_addFriend"))
    end
  end
end

function M:setPanelPos(x, y)
  local finalY = math.min(y, self.rootHeight - self.panelHeight)
  self.Panel:setPosition(UDim2.new(0, x, 0, finalY))
end

function M:onOpen()
  self:setUsingAutoRenderingSurface(true)
end

function M:sendInviteMsg(userId)
  ChatHelper:sendInviteMsg(userId)
end

M:init()

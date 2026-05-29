local chatSetting = World.cfg.chatSetting

function M:init()
  self.friendInfData = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.panelHead = self.PanelHead
  self.widgetHead = UI:openWidget("./UI/new_chat/gui/widget_chat_player_head")
  self.panelHead:addChild(self.widgetHead)
end

function M:initEvent()
end

function M:initData(data)
  self.friendInfData = data
  if data then
    self.TextName:setText(data.friendData.nickName)
    self.TextLang:setText(data.friendData.language)
    local isOffline = data.friendData.status == Define.onlineStatus.offline
    local cfg = chatSetting.friendPanelCfg.onlineStatusColor
    if isOffline then
      self.TextOnline:setText(Lang:toText("new.chat.status.offline"))
      self.TextOnline:setProperty("TextColours", cfg.offline or "FFFF0000")
    else
      self.TextOnline:setText(Lang:toText("new.chat.status.online"))
      self.TextOnline:setProperty("TextColours", cfg.online or "FF00FF00")
    end
    local detailInf = {
      userId = data.friendData.userId,
      nickName = data.friendData.nickName,
      sex = data.friendData.sex,
      picUrl = data.friendData.picUrl
    }
    self.widgetHead:initData(detailInf)
  end
end

M:init()

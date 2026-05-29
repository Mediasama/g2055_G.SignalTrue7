function M:init()
  self.applyPlayerData = nil
  
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.panelHead = self.PanelHead
  self.widgetHead = UI:openWidget("./UI/new_chat/gui/widget_chat_player_head")
  self.panelHead:addChild(self.widgetHead)
end

function M:initEvent()
  function self.ButtonAccept.onWindowClick()
    if self.applyPlayerData then
      Lib.emitEvent(Event.EVENT_RESPONSE_FRIEND_APPLY, self.applyPlayerData.userId, true)
    end
  end
  
  function self.ButtonReject.onWindowClick()
    if self.applyPlayerData then
      Lib.emitEvent(Event.EVENT_RESPONSE_FRIEND_APPLY, self.applyPlayerData.userId, false)
    end
  end
end

function M:initData(data)
  self.applyPlayerData = data
  if not data then
    return
  end
  self.TextName:setText(self.applyPlayerData.nickName)
  self.TextLang:setText(self.applyPlayerData.language)
  local detailInf = {
    userId = self.applyPlayerData.userId,
    nickName = self.applyPlayerData.nickName,
    sex = self.applyPlayerData.sex,
    picUrl = self.applyPlayerData.picUrl
  }
  self.widgetHead:initData(detailInf)
end

M:init()

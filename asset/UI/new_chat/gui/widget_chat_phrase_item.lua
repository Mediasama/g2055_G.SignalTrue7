local ChatHelper = T(World, "ChatHelper")

function M:init()
  self.phraseId = ""
  self:initUI()
  self:initEvent()
end

function M:initUI()
end

function M:initEvent()
  function self.TextPhrase.onWindowClick()
    self:sendPhrase()
  end
end

function M:sendPhrase()
  local chatPage = ChatHelper:getCurPage()
  local chatTarget = ChatHelper:getCurChatTarget()
  if not ChatHelper:canSend(chatPage) then
    Client.ShowTip(1, Lang:toText("new.chat.can.not.send"), Define.TipsShowTime)
    return
  end
  print("M:sendPhrase() ", chatPage, chatTarget)
  ChatHelper:sendChatMsg(chatPage, {
    fromId = Me.platformUserId,
    msg = self.phraseId,
    msgType = Define.MsgType.ShortMsg,
    targetUserId = chatTarget
  })
end

function M:setData(cfg)
  if cfg then
    self.phraseId = cfg.id
    self.TextPhrase:setText(cfg.name)
  end
end

M:init()

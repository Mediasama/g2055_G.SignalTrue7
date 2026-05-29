local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\129\228\184\150\231\149\140\232\129\138\229\164\169"] = GM:inputStr(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.World, {
    fromId = Me.platformUserId,
    msg = val,
    msgType = Define.MsgType.Text
  })
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\129\231\167\129\232\129\138"] = GM:inputNumber(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.Private, {
    fromId = Me.platformUserId,
    msg = "\231\167\129\232\129\138\228\191\161\230\129\175",
    msgType = Define.MsgType.Text,
    targetUserId = val
  })
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\12920\230\157\161\228\184\150\231\149\140\230\182\136\230\129\175"] = function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  for i = 1, 20 do
    ChatHelper:sendChatMsg(Define.ChatPage.World, {
      fromId = Me.platformUserId,
      msg = i,
      msgType = Define.MsgType.Text
    })
  end
end
local sendIndex = 0
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/10\229\184\167\228\184\128\230\157\161\228\184\150\231\149\140\230\182\136\230\129\175"] = function(self, val)
  if self.gmAutoSendMsgTimer then
    self.gmAutoSendMsgTimer()
    self.gmAutoSendMsgTimer = nil
    sendIndex = 0
    return
  end
  self.gmAutoSendMsgTimer = World.Timer(10, function()
    local ChatHelper = T(World, "ChatHelper")
    sendIndex = sendIndex + 1
    ChatHelper:sendChatMsg(Define.ChatPage.World, {
      fromId = Me.platformUserId,
      msg = sendIndex,
      msgType = Define.MsgType.Text
    })
    return true
  end)
end
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\129\232\161\168\230\131\133"] = function(self)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.World, {
    fromId = Me.platformUserId,
    msg = 1,
    msgType = Define.MsgType.Emoji
  })
end
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\129\229\191\171\230\141\183\232\175\173"] = function(self)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.World, {
    fromId = Me.platformUserId,
    msg = 1,
    msgType = Define.MsgType.ShortMsg
  })
end
local event
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\129\232\175\173\233\159\179"] = function(self)
  if not event then
    event = Lib.lightSubscribeEvent("", Event.EVENT_CHAT_SEND_VOICE, function(time, url)
      local ChatHelper = T(World, "ChatHelper")
      ChatHelper:sendChatMsg(Define.ChatPage.World, {
        fromId = Me.platformUserId,
        msg = {uri = url, voiceTime = time},
        msgType = Define.MsgType.Voice
      })
    end)
  end
  VoiceManager:startRecord()
  World.Timer(40, function()
    VoiceManager:stopRecord()
  end)
end
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\231\167\129\232\129\138\232\161\168\230\131\133"] = GM:inputNumber(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.Private, {
    fromId = Me.platformUserId,
    msg = 1,
    msgType = Define.MsgType.Emoji,
    targetUserId = val
  })
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\231\167\129\232\129\138\229\191\171\230\141\183\232\175\173"] = GM:inputNumber(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.Private, {
    fromId = Me.platformUserId,
    msg = 1,
    msgType = Define.MsgType.ShortMsg,
    targetUserId = val
  })
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\231\167\129\232\129\138\232\175\173\233\159\179"] = GM:inputNumber(function(self, val)
  if not event then
    event = Lib.lightSubscribeEvent("", Event.EVENT_CHAT_SEND_VOICE, function(time, url)
      local ChatHelper = T(World, "ChatHelper")
      ChatHelper:sendChatMsg(Define.ChatPage.Private, {
        fromId = Me.platformUserId,
        msg = {uri = url, voiceTime = time},
        msgType = Define.MsgType.Voice,
        targetUserId = val
      })
    end)
  end
  VoiceManager:startRecord(val)
  World.Timer(40, function()
    VoiceManager:stopRecord(val)
  end)
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\232\142\183\229\143\150\231\167\129\232\129\138\229\142\134\229\143\178\230\182\136\230\129\175"] = GM:inputNumber(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:checkHistoryIsLoad(val)
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\185\191\230\146\173\230\182\136\230\129\175"] = function(self)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendCrossServerMsg({
    fromId = Me.platformUserId,
    msg = 1,
    msgType = Define.MsgType.Text
  })
end
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\136\135\230\141\162\232\129\138\229\164\169\233\162\145\233\129\147"] = GM:inputStr(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:joinChatChannel(val)
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\229\143\145\233\128\129\231\179\187\231\187\159\230\182\136\230\129\175"] = GM:inputStr(function(self, val)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper:sendChatMsg(Define.ChatPage.System, {
    msg = val,
    msgType = Define.MsgType.Text
  })
end)
GMItem["\232\129\138\229\164\169\230\143\146\228\187\182/\232\167\163\233\153\164\229\143\145\230\182\136\230\129\175\233\153\144\229\136\182"] = function(self)
  local ChatHelper = T(World, "ChatHelper")
  ChatHelper.cheatNoSendLimit = true
end
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\230\156\136\229\141\161\230\184\133\233\155\182"] = function(self)
  Me:sendPacket({
    pid = "clearMoonCardTest"
  })
end

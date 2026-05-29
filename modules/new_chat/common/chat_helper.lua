local ChatHelper = T(World, "ChatHelper")
local cjson = require("cjson")
local MsgType = Define.MsgType
local ChatPage = Define.ChatPage
local PrivateMessageType = Define.PrivateMessageType
local ChatMsgManager = T(World, "ChatMsgManager")
local ShortConfig = T(Config, "ShortConfig")
local ChatConnectorSender = T(Lib, "ChatConnectorSender")
local EmojiConfig = T(Config, "EmojiConfig")

function ChatHelper:init()
  self.unloadPrivateHistoryMsgDic = {}
  self.latestMessageIdDict = {}
  self.cachePrivateNewMsgDic = {}
  self.userHeadCacheList = {}
  self.getUserDetailUserId = {}
  self.newMsgCounter = {}
  self.duration = World.cfg.chatSetting.sendMsgIntervalLimit or 3
  self.lastSendTime = {}
  self.needGetOnlineList = {}
  self.playerOnlineStateCache = {}
  self:initEvent()
  World.Timer(1, function()
    self:initDetailInfo(Me.platformUserId)
  end)
end

function ChatHelper:initEvent()
  Lib.lightSubscribeEvent("", Event.EVENT_RECEIVE_CHAT_MESSAGE, function(msgData)
    if not msgData then
      return
    end
    if msgData.pageType ~= ChatPage.Private then
      self:initDetailInfo(msgData.fromId)
    end
    ChatMsgManager:pushMsg(msgData)
  end)
  Lib.lightSubscribeEvent("", Event.LOAD_USER_DETAIL_FINISH, function(data)
    self:joinChatChannel(data.language)
  end)
  Lib.lightSubscribeEvent("", Event.EVENT_PUSH_CHAT_MSG, function(msgData)
    self:updateNewMsgCounter(msgData.pageType, msgData.keyId, 1)
  end)
end

function ChatHelper:joinChatChannel(language)
  local chatRoomKey = World.GameName .. "_" .. language
  Lib.logInfo("joinChatChannel  ", chatRoomKey)
  ChatConnectorSender:joinChatChannel(chatRoomKey, World.cfg.chatSetting.chatRoomMaxPlayerNum)
end

function ChatHelper:sendChatMsg(pageType, msgData)
  if World.isClient then
    self:setSendMsgTime(pageType)
    if msgData.msgType ~= MsgType.Voice then
      msgData.msg = World.CurWorld:filterWord(Lib.stringTrim(msgData.msg) or "")
    end
    if pageType == ChatPage.Private then
      if msgData.msgType == MsgType.Voice then
      else
        self:sendPrivateMsg(msgData)
      end
    elseif pageType == ChatPage.CrossServer then
      self:sendCrossServerMsg(msgData)
    else
      self:sendNormalChat(pageType, msgData)
    end
    Me:sendMsgReport(pageType, msgData.msgType)
  end
end

function ChatHelper:sendNormalChat(pageType, msgData)
  if World.isClient then
    local packet = {
      pid = "SendChatMsgToServer",
      msgData = msgData,
      pageType = pageType
    }
    Me:sendPacket(packet)
  end
end

function ChatHelper:sendCrossServerMsg(msgData)
  local msgData = {
    fromName = Me.name,
    msg = msgData.msg,
    msgType = msgData.msgType,
    pageType = ChatPage.CrossServer,
    objID = Me.objID,
    fromId = msgData.fromId
  }
  ChatConnectorSender:sendCrossServerGameMsg(msgData)
end

function ChatHelper:getPageMsgList(pageType, key)
  local msgList = ChatMsgManager:getPageMsgList(pageType, key)
  return msgList
end

function ChatHelper:getPageMsgListGroup(pageType)
  local msgListGroup = ChatMsgManager:getPageMsgListGroup(pageType)
  return msgListGroup
end

function ChatHelper:getMiniMsgList()
  return ChatMsgManager.miniChatMsg or {}
end

function ChatHelper:clearMsgList(pageType, targetId)
  ChatMsgManager:clearMsgByType(pageType, targetId)
end

function ChatHelper:getLatestMsg(pageType, targetId)
  Lib.logInfo("ChatHelper:getLatestMsg(pageType, targetId)", pageType, targetId)
  return ChatMsgManager:getLatestMsg(pageType, targetId)
end

function ChatHelper:sendPrivateMsg(msgData)
  if not msgData.targetUserId then
    return
  end
  local msgType = PrivateMessageType.txtMsg
  if msgData.msgType == MsgType.Emoji then
    msgType = PrivateMessageType.EmojiMsg
  elseif msgData.msgType == MsgType.Voice then
    msgType = PrivateMessageType.VoiceMsg
  end
  local privateMsg = self:encodeJsonPrivateMsg(msgData)
  CGame.instance:getShellInterface():onSendMessage(msgType, privateMsg)
end

function ChatHelper:checkHistoryIsLoad(userId)
  userId = tonumber(userId)
  if self.unloadPrivateHistoryMsgDic[userId] then
    if self.unloadPrivateHistoryMsgDic[userId] > 0 then
      self.unloadPrivateHistoryMsgDic[userId] = -1
      CGame.instance:getShellInterface():onGetTalkDetail(userId, self.unloadPrivateHistoryMsgDic[userId], 10)
    end
    return true
  end
  return false
end

function ChatHelper:receivePlatformPrivateMsg(sourceType, messageType, content, isHistory)
  Lib.logWarning("=====receivePlatformPrivateMsg  ", sourceType, messageType, content, isHistory)
  local privateMsg = self:decodeJsonPrivateMsg(sourceType, messageType, content)
  if not privateMsg then
    return
  end
  self:addPrivateMsg(privateMsg, isHistory)
end

function ChatHelper:addPrivateMsg(privateMsg, isHistory)
  Lib.logInfo("+++++++++++++++++++++++++++++++ChatHelper:addPrivateMsg()   ", privateMsg, isHistory)
  local keyId
  if tonumber(privateMsg.senderUserId) == Me.platformUserId then
    keyId = tonumber(privateMsg.receiverUserId)
  else
    keyId = tonumber(privateMsg.senderUserId)
  end
  self:initDetailInfo(keyId)
  self:addOneNeedOnlineItem(keyId)
  if self:checkHistoryIsLoad(keyId) then
    if not self.cachePrivateNewMsgDic[keyId] then
      self.cachePrivateNewMsgDic[keyId] = {}
    end
    table.insert(self.cachePrivateNewMsgDic[keyId], privateMsg)
    return
  end
  local msgData = {
    pageType = ChatPage.Private,
    senderUserId = tonumber(privateMsg.senderUserId),
    fromId = tonumber(privateMsg.senderUserId),
    fromName = privateMsg.senderNickname or privateMsg.senderUserId,
    toUserId = tonumber(privateMsg.receiverUserId),
    keyId = keyId,
    msgType = privateMsg.msgType,
    msg = privateMsg.msg,
    isHistory = isHistory,
    sentTime = privateMsg.sentTime
  }
  ChatMsgManager:pushMsg(msgData)
  return keyId
end

function ChatHelper:receiveHistoryTalkList(listInfo)
  Lib.logInfo("receiveHistoryTalkList ")
  Lib.pv(listInfo, 3)
  local listTb = self:safeDecodeJSON(listInfo, {})
  for _, item in pairs(listTb) do
    self:receivePlatformPrivateMsg(false, false, item.latestMessage, true)
    self.latestMessageIdDict[tonumber(item.targetId)] = item.latestMessageId
    self.unloadPrivateHistoryMsgDic[tonumber(item.targetId)] = item.latestMessageId
    self:checkHistoryIsLoad(item.targetId)
  end
end

function ChatHelper:receiveHistoryTalkDetail(targetId, detailContent)
  Lib.logInfo("+++++++++++++++++++receiveHistoryTalkDetail ", targetId, detailContent)
  targetId = tonumber(targetId)
  local detailTb = self:safeDecodeJSON(detailContent)
  Lib.pv(detailTb, 3)
  local latestMessageId = self.latestMessageIdDict[targetId] or 0
  self.unloadPrivateHistoryMsgDic[targetId] = false
  self:clearMsgList(ChatPage.Private, targetId)
  local decodeMsgList = {}
  for _, item in pairs(detailTb) do
    local data = self:decodeJsonPrivateMsg(false, false, item)
    Lib.logInfo("+++++++++++++++++++decodeJsonPrivateMsg ", data)
    if not data then
      return
    end
    if data.messageId then
      table.insert(decodeMsgList, data)
    end
  end
  table.sort(decodeMsgList, function(a, b)
    return a.messageId < b.messageId
  end)
  local keyId
  for i, item in ipairs(decodeMsgList) do
    if latestMessageId >= item.messageId then
      keyId = self:addPrivateMsg(item, true)
    end
  end
  if self.cachePrivateNewMsgDic[targetId] then
    for _, cache in pairs(self.cachePrivateNewMsgDic[targetId]) do
      keyId = self:addPrivateMsg(cache)
    end
    self.cachePrivateNewMsgDic[targetId] = nil
  end
  Lib.logInfo("+++++++++++++++++++EVENT_GET_PRIVATE_HISTORY ", keyId)
  Lib.emitEvent(Event.EVENT_GET_PRIVATE_HISTORY, keyId)
end

function ChatHelper:encodeJsonPrivateMsg(msgData)
  local msg = msgData.msg
  if msgData.msgType == MsgType.ShortMsg then
    local shortMsgCfg = ShortConfig:getCfgById(tonumber(msg))
    if shortMsgCfg then
      msg = shortMsgCfg.text
    end
  end
  local content = {
    receivedTime = 0,
    sentTime = os.time(),
    senderUserId = tostring(Me.platformUserId),
    senderNickname = Me.name,
    receiverUserId = tostring(msgData.targetUserId),
    conversationType = "private",
    content = msg
  }
  if msgData.msgType == MsgType.Voice then
    content.content = nil
    content.uri = msg.uri
    content.duration = msg.voiceTime / 1000
  end
  local resultStr = cjson.encode(content)
  return resultStr
end

function ChatHelper:decodeJsonPrivateMsg(sourceType, messageType, content)
  local privateMsg = self:safeDecodeJSON(content)
  if not privateMsg then
    return false
  end
  local msgData = {}
  sourceType = sourceType or privateMsg.sourceType
  messageType = messageType or privateMsg.messageType
  if sourceType == Define.PrivateMessageSource.GameMsg then
    if messageType == Define.PrivateMessageType.EmojiMsg then
      msgData.msgType = MsgType.Emoji
      msgData.msg = tonumber(privateMsg.content)
    elseif messageType == Define.PrivateMessageType.VoiceMsg then
      msgData.msgType = MsgType.Voice
      msgData.msg = {
        uri = privateMsg.uri or "",
        voiceTime = privateMsg.duration * 1000
      }
    else
      msgData.msgType = MsgType.Text
      local shortMsgCfg = ShortConfig:getShortMsgByText(privateMsg.content or "")
      if shortMsgCfg then
        msgData.msgType = MsgType.ShortMsg
        msgData.msg = shortMsgCfg.id
      else
        msgData.msgType = MsgType.Text
        msgData.msg = privateMsg.content or ""
      end
    end
  elseif messageType == Define.PrivateMessageType.TxtMsg then
    msgData.msgType = MsgType.Text
    msgData.msg = Lib.stringTrim(privateMsg.content or "")
  elseif messageType == Define.PrivateMessageType.VoiceMsg then
    msgData.msgType = MsgType.Voice
    msgData.msg = {
      uri = privateMsg.uri or "",
      voiceTime = privateMsg.duration * 1000
    }
  elseif messageType == Define.PrivateMessageType.EmojiMsg then
    local emojiId = tonumber(privateMsg.content)
    local data = EmojiConfig:getCfgById(emojiId)
    if data then
      msgData.msgType = MsgType.Emoji
      msgData.msg = emojiId
    else
      msgData.msgType = MsgType.Text
      msgData.msg = Lang:toText("new.chat.tips.unable_display")
    end
  else
    msgData.msgType = MsgType.Text
    msgData.msg = Lang:toText("new.chat.tips.unable_display")
  end
  msgData.senderUserId = privateMsg.senderUserId
  msgData.receiverUserId = privateMsg.receiverUserId
  msgData.receivedTime = privateMsg.receivedTime
  msgData.messageId = privateMsg.messageId
  msgData.sentTime = privateMsg.sentTime
  return msgData
end

function ChatHelper:initDetailInfo(userId)
  if not userId then
    return
  end
  if self.userHeadCacheList[userId] or self.getUserDetailUserId[userId] then
    return
  end
  self.getUserDetailUserId[userId] = true
  AsyncProcess.GetUserDetail(userId, function(data)
    self.getUserDetailUserId[userId] = false
    if not self.userHeadCacheList[userId] then
      self.userHeadCacheList[userId] = {}
    end
    self.userHeadCacheList[userId].detailInfo = {}
    self.userHeadCacheList[userId].detailInfo.nickName = ""
    self.userHeadCacheList[userId].detailInfo.sex = 1
    self.userHeadCacheList[userId].detailInfo.userId = userId
    if data then
      if data.picUrl and #data.picUrl > 0 then
        self.userHeadCacheList[userId].detailInfo.picUrl = data.picUrl
      end
      self.userHeadCacheList[userId].detailInfo.nickName = data.nickName
      self.userHeadCacheList[userId].detailInfo.sex = data.sex
    end
    if self.userHeadCacheList[userId] then
      print("Lib.emitEvent(EVENT_USER_DETAIL): ", userId)
      Lib.emitEvent("EVENT_USER_DETAIL" .. userId, self.userHeadCacheList[userId].detailInfo)
    end
  end)
end

function ChatHelper:getUserDetailInfo(userId)
  return self.userHeadCacheList[userId] and self.userHeadCacheList[userId].detailInfo or false
end

function ChatHelper:safeDecodeJSON(content, def)
  local ok, ret = xpcall(cjson.decode, debug.traceback, content)
  if not ok then
    print("json decode fail:", Lib.v2s(content, 2))
    return def or false
  end
  return ret
end

function ChatHelper:safeEncodeJSON(tb)
  local ok, ret = xpcall(cjson.encode, debug.traceback, tb)
  if not ok then
    print("json encode fail:", Lib.v2s(tb, 2))
    return false
  end
  return ret
end

function ChatHelper:getColorOfRGB(colorStr)
  local newstr = string.gsub(colorStr, "#", "")
  local colorlist = {}
  local index = 1
  while index < string.len(newstr) do
    local tempstr = string.sub(newstr, index, index + 1)
    table.insert(colorlist, tonumber(tempstr, 16))
    index = index + 2
  end
  return {
    (colorlist[1] or 0) / 255,
    (colorlist[2] or 0) / 255,
    (colorlist[3] or 0) / 255
  }
end

function ChatHelper:getCurPage()
  local winMain = UI:isOpenWindow("./UI/new_chat/gui/win_chat_main")
  if winMain then
    return winMain.curTab
  end
  return Define.ChatPage.World
end

function ChatHelper:getCurChatTarget()
  local winMain = UI:isOpenWindow("./UI/new_chat/gui/win_chat_main")
  if winMain then
    return winMain.privateChatTarget
  end
  return nil
end

function ChatHelper:updateNewMsgCounter(chatPage, keyId, num)
  if not chatPage then
    return
  end
  if chatPage == Define.ChatPage.Private then
    if self.newMsgCounter[chatPage] == nil then
      self.newMsgCounter[chatPage] = {}
    end
    if self.newMsgCounter[chatPage][keyId] == nil then
      self.newMsgCounter[chatPage][keyId] = 0
    end
    self.newMsgCounter[chatPage][keyId] = self.newMsgCounter[chatPage][keyId] + num
  else
    if self.newMsgCounter[chatPage] == nil then
      self.newMsgCounter[chatPage] = 0
    end
    self.newMsgCounter[chatPage] = self.newMsgCounter[chatPage] + num
  end
  Lib.emitEvent(Event.EVENT_CHAT_UPDATE_RED_POINT, chatPage, keyId)
end

function ChatHelper:getNewMsgCounter(chatPage, keyId)
  if not self.newMsgCounter[chatPage] then
    return 0
  end
  if chatPage == Define.ChatPage.Private then
    if keyId == nil then
      local sum = 0
      for _, v in pairs(self.newMsgCounter[chatPage]) do
        sum = sum + v
      end
      return sum
    else
      return self.newMsgCounter[chatPage][keyId] or 0
    end
  else
    return self.newMsgCounter[chatPage]
  end
end

function ChatHelper:clearNewMsgCounter(chatPage, keyId)
  print("ChatHelper:clearNewMsgCounter(chatPage,keyId,num) ", chatPage, keyId)
  if not self.newMsgCounter[chatPage] then
    return
  end
  if chatPage == Define.ChatPage.Private then
    self.newMsgCounter[chatPage][keyId] = 0
  else
    self.newMsgCounter[chatPage] = 0
  end
  Lib.emitEvent(Event.EVENT_CHAT_UPDATE_RED_POINT, chatPage, keyId)
end

function ChatHelper:setSendMsgTime(chatPage)
  if not chatPage then
    return
  end
  self.lastSendTime[chatPage] = World.Now()
end

function ChatHelper:canSend(chatPage)
  if not chatPage then
    return false
  end
  if self.cheatNoSendLimit then
    return true
  end
  if not self.lastSendTime[chatPage] then
    return true
  end
  return World.Now() - self.lastSendTime[chatPage] >= self.duration * 20
end

function ChatHelper:checkShowTab(chatPage)
  if chatPage == Define.ChatPage.Gang then
    return Plugins.CallTargetPluginFunc("gangs", "playerHasGang")
  else
    return true
  end
end

function ChatHelper:addOneNeedOnlineItem(item)
  if not item then
    return
  end
  if type(item) == "table" then
    for _, val in pairs(item) do
      if val.userId then
        self.needGetOnlineList[val.userId] = true
      end
    end
  else
    self.needGetOnlineList[item] = true
  end
end

function ChatHelper:getNeedOnlineList()
  local userIds = {}
  for userId, val in pairs(self.needGetOnlineList) do
    table.insert(userIds, userId)
  end
  return userIds
end

function ChatHelper:getChatPlayerOnlineState(userId)
  return self.playerOnlineStateCache[userId] or Define.onlineStatus.offline
end

function ChatHelper:requestPlayerOnlineState()
  local userIds = self:getNeedOnlineList()
  if 0 < #userIds then
    local function callFunc(data)
      self.playerOnlineStateCache = {}
      
      for _, onlineData in pairs(data) do
        self.playerOnlineStateCache[onlineData.userId] = onlineData.status
      end
      Lib.emitEvent(Event.EVENT_UPDATE_ONLINE_STATE_SHOW)
    end
    
    AsyncProcess.GetPlayerOnlineState(userIds, callFunc)
  end
end

local inviteLock = false

function ChatHelper:sendInviteMsg(userId)
  local player = Game.GetPlayerByUserId(userId)
  if player then
    Client.ShowTip(1, Lang:toText("new.chat.invite.isExist"), Define.TipsShowTime)
    return
  end
  if inviteLock then
    Client.ShowTip(1, Lang:toText("new.chat.invite.toofast"), Define.TipsShowTime)
    return false
  end
  inviteLock = true
  World.LightTimer("", 60, function()
    inviteLock = false
  end)
  CGame.instance:getShellInterface():onSendMessage(Define.PrivateMessageType.InviteMsg, userId)
  Client.ShowTip(1, Lang:toText("new.chat.invite.succ"), Define.TipsShowTime)
end

local Player = _ENV.Player
local ChatPage = Define.ChatPage
local ChatHelper = T(World, "ChatHelper")

function Player:showChatBubble(msgData)
  if msgData.pageType ~= ChatPage.World then
    return
  end
  local chatBubbleSetting = World.cfg.chatSetting.chatBubbleSetting
  local entity = World.CurWorld:getEntity(msgData.objID)
  if entity and entity:isValid() then
    local args = {
      position = Vector3.new(0, chatBubbleSetting.offsetY, 0),
      width = chatBubbleSetting.bubbleWinSize.width,
      height = chatBubbleSetting.bubbleWinSize.height,
      objID = entity.objID,
      flags = 4
    }
    local sceneWindow, headBubbleInstance
    headBubbleInstance = entity.headBubbleInstance
    if not headBubbleInstance then
      sceneWindow, headBubbleInstance = UI:openNewSceneWindow("./UI/new_chat/gui/win_head_bubble", "win_head_bubble" .. entity.objID, args, "asset", entity.objID)
      entity.headBubbleInstance = headBubbleInstance
    end
    if headBubbleInstance then
      headBubbleInstance:insertMsg(msgData)
    end
  end
end

function Player:getVoiceCardTime()
  self:sendPacket({
    pid = "GetVoiceCardTime"
  }, function(time)
    Lib.emitEvent(Event.EVENT_CHAT_CARD_TIME, time)
  end)
end

function Player:getSoundTimesString()
  if self:getSoundMoonCardEnable() then
    return "*"
  elseif self:getSoundTimes() > 0 then
    return tostring(Me:getSoundTimes())
  elseif 0 < self:getFreeSoundTimes() then
    return tostring(Me:getFreeSoundTimes())
  else
    return ""
  end
end

World.Timer(1, function()
  Lib.subscribeEvent(Event.EVENT_EXIT_GANG, function()
    ChatHelper:clearMsgList(ChatPage.Gang)
  end)
end)

function Player:sendMsgReport(pageType, msgType)
  self:sendMsgReportGang(pageType, msgType)
  local pageTypeTrans = {}
  pageTypeTrans[Define.ChatPage.Private] = Define.EventTracking.ChatInf.Type.Private
  pageTypeTrans[Define.ChatPage.Gang] = Define.EventTracking.ChatInf.Type.Gang
  pageTypeTrans[Define.ChatPage.World] = Define.EventTracking.ChatInf.Type.World
  local msgTypeTrans = {}
  msgTypeTrans[Define.MsgType.Text] = Define.EventTracking.ChatInf.InfType.Text
  msgTypeTrans[Define.MsgType.Voice] = Define.EventTracking.ChatInf.InfType.Voice
  msgTypeTrans[Define.MsgType.Emoji] = Define.EventTracking.ChatInf.InfType.Emoji
  local reportPageType = pageTypeTrans[pageType]
  local reportMsgType = msgTypeTrans[msgType]
  if not reportPageType or not reportMsgType then
    return
  end
  local reportData = {}
  reportData.type_g2055 = reportPageType
  reportData.info_type = reportMsgType
  self:evt_reportEvent(Define.EventTracking.Type.ChatInf, reportData, true)
end

function Player:sendMsgReportGang(pageType, msgType)
  if pageType ~= Define.ChatPage.Gang then
    return
  end
  local opTypeTrans = {}
  opTypeTrans[Define.MsgType.Text] = Define.GangOperationType.Chat
  opTypeTrans[Define.MsgType.Voice] = Define.GangOperationType.Voice
  local opType = opTypeTrans[msgType]
  if not opType then
    return
  end
  self:evt_player_team_operation(opType)
end

function Player:friendRequestReport(operationType, friendId, isSender)
  local opTypeTrans = {}
  if isSender then
    opTypeTrans[FriendManager.operationType.ADD_FRIEND] = Define.EventTracking.AddFriend.Status.SendInvite
    opTypeTrans[FriendManager.operationType.AGREE] = Define.EventTracking.AddFriend.Status.AgreeInvite
    opTypeTrans[FriendManager.operationType.REFUSE] = Define.EventTracking.AddFriend.Status.RefuseInvite
  else
    opTypeTrans[FriendManager.operationType.ADD_FRIEND] = Define.EventTracking.AddFriend.Status.ReceiveInvite
    opTypeTrans[FriendManager.operationType.AGREE] = Define.EventTracking.AddFriend.Status.InviteSuccess
    opTypeTrans[FriendManager.operationType.REFUSE] = Define.EventTracking.AddFriend.Status.InviteFail
  end
  local reportOpType = opTypeTrans[operationType]
  if not reportOpType or not friendId then
    return
  end
  local reportData = {}
  reportData.status = reportOpType
  reportData.friend_id = friendId
  self:evt_reportEvent(Define.EventTracking.Type.AddFriend, reportData, true)
end

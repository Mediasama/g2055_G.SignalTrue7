require("common.entity_new_chat")
require("common.event_new_chat")
require("common.define_new_chat")
require("common.chat_msg_manager")
require("common.chat_helper")
require("common.config.short_config")
require("common.config.emoji_config")
require("common.config.voice_shop_config")
if World.isClient then
  require("client.chat_ui_helper")
  require("client.player.player_new_chat")
  require("client.player.player_new_chat_friend")
  require("client.player.packet_new_chat")
  require("client.player.player_event_chat")
  require("client.entity.entity_new_chat")
  require("client.entity.entity_value_func_new_chat")
  require("client.gm_new_chat")
  require("client.connector.chat_connector_handler")
  require("client.connector.chat_connector_sender")
  require("client.async_process_friend")
  Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() and entity.headBubbleInstance then
      entity.headBubbleInstance:onClose()
      entity.headBubbleInstance = nil
      UI:closeSceneWindow("win_head_bubble" .. entity.objID)
    end
  end)
else
  require("server.player.player_new_chat")
  require("server.player.player_new_chat_friend")
  require("server.player.packet_new_chat")
  require("server.entity.entity_new_chat")
  require("server.gm_new_chat")
  require("server.async_process_friend")
end
local operationType = FriendManager.operationType
Lib.subscribeEvent(Event.EVENT_FRIEND_OPERATION_NOTICE, function(opType, playerPlatformId)
  print("===================== Event.EVENT_FRIEND_OPERATION_NOTICE ", opType, playerPlatformId)
  if opType == operationType.AGREE then
    Me:doRequestServerFriendInfo(Define.chatFriendType.game)
    Me:doRequestServerFriendInfo(Define.chatFriendType.platform)
    Me:addPlayerFriendFromExist(playerPlatformId, Define.friendStatus.gameFriend)
  elseif opType == operationType.DELETE then
    Me:doRequestServerFriendInfo(Define.chatFriendType.game)
    Me:doRequestServerFriendInfo(Define.chatFriendType.platform)
    Me:removePlayerFriendFromExist(playerPlatformId)
  elseif opType == operationType.ADD_FRIEND then
    AsyncProcess.LoadUserRequests()
  end
  Me:friendRequestReport(opType, playerPlatformId, false)
end)
local ChatHelper = T(World, "ChatHelper")
local ChatMsgManager = T(World, "ChatMsgManager")
ChatMsgManager:init()
ChatHelper:init()
local handlers = {}

function handlers.onGameReady()
  CGame.instance:getShellInterface():onGetTalkList(0, World.cfg.chatSetting.maxHistory or 10)
  World.Timer(1, function()
    Me:doRequestServerFriendInfo(Define.chatFriendType.game, 0)
    Me:doRequestServerFriendInfo(Define.chatFriendType.platform, 0)
    Lib.emitEvent(Event.EVENT_UI_OPEN_CHAT_MINI)
  end)
end

function handlers.OnPlayerLogin(player)
  player:loginRequestFriendInfo()
  player:updateFreeSoundFlag()
  player:checkVoiceMoonEnable()
end

function handlers.doRequestServerSendChatMsg(pageType, msgData)
  if World.isClient then
    ChatHelper:sendChatMsg(pageType, msgData)
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

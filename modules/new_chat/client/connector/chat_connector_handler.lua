local ChatConnectorHandler = {}
local ConnectorDispatch = T(Lib, "ConnectorDispatch")
local cjson = require("cjson")
local Game2ConnectorMsgType = {
  ReceiveCrossServerGameMsg = 30016,
  JoinChatChannelResult = 30113,
  LeaveChatChannelResult = 30114
}

function ChatConnectorHandler:init()
  self:initMsgFunc()
end

function ChatConnectorHandler:initMsgFunc()
  ConnectorDispatch:registerFunc(Game2ConnectorMsgType.ReceiveCrossServerGameMsg, self.onReceiveCrossServerGameMsg, self)
  ConnectorDispatch:registerFunc(Game2ConnectorMsgType.JoinChatChannelResult, self.onJoinChatChannelResult, self)
  ConnectorDispatch:registerFunc(Game2ConnectorMsgType.LeaveChatChannelResult, self.onLeaveChatChannelResult, self)
end

function ChatConnectorHandler:onReceiveCrossServerGameMsg(_, targets, data)
  Lib.emitEvent(Event.EVENT_RECEIVE_CHAT_MESSAGE, data)
  return true
end

function ChatConnectorHandler:onJoinChatChannelResult(_, targets, data)
  Lib.emitEvent(Event.EVENT_JOIN_CHANNEL_SUCCESS)
  return true
end

function ChatConnectorHandler:onLeaveChatChannelResult(_, targets, data)
  return true
end

ChatConnectorHandler:init()

local baseMsgList = require("common.base_msg_list")
local PrivateMsgList = class("PrivateMsgList", baseMsgList)

function PrivateMsgList:ctor(pageType)
  baseMsgList.ctor(self, pageType)
end

function PrivateMsgList:pushMsg(keyId, msg)
  if not self.msgList[keyId] then
    self.msgList[keyId] = {}
  end
  self:checkMsgLimitCount(keyId)
  table.insert(self.msgList[keyId], msg)
end

function PrivateMsgList:checkMsgLimitCount(keyId)
  if #self.msgList[keyId] >= self.msgLimitCount then
    table.remove(self.msgList[keyId], 1)
  end
end

function PrivateMsgList:getLatestMsg(num, keyId)
  local list = {}
  local msg = self.msgList[keyId]
  if not msg then
    return list
  end
  local count = #msg
  if num > count then
    num = 0
  end
  for i = count - num + 1, count do
    table.insert(list, msg[i])
  end
  return list
end

function PrivateMsgList:getMsgList(key)
  return self.msgList[key] or {}
end

function PrivateMsgList:getMsgListGroup()
  return self.msgList
end

function PrivateMsgList:clearMsg(targetId)
  self.msgList[targetId] = {}
end

return PrivateMsgList

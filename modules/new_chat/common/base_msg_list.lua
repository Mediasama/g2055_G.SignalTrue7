local BaseMsgList = class("BaseMsgList")

function BaseMsgList:ctor(pageType)
  self.msgList = {}
  self.pageType = pageType
  self.msgLimitCount = World.cfg.chatSetting.pageMsgMaxCount
end

function BaseMsgList:pushMsg(fromId, msg)
  self:checkMsgLimitCount()
  table.insert(self.msgList, msg)
end

function BaseMsgList:checkMsgLimitCount()
  if #self.msgList >= self.msgLimitCount then
    table.remove(self.msgList, 1)
  end
end

function BaseMsgList:getLatestMsg(num)
  local list = {}
  local count = #self.msgList
  if num > count then
    num = 0
  end
  for i = count - num + 1, count do
    table.insert(list, self.msgList[i])
  end
  return list
end

function BaseMsgList:getMsgList(key)
  return self.msgList
end

function BaseMsgList:getMsgListGroup()
  return {}
end

function BaseMsgList:clearMsg()
  self.msgList = {}
end

return BaseMsgList

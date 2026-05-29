local MsgType = Define.MsgType
local miniChatCfg = World.cfg.chatSetting.miniChatCfg
local EmojiConfig = T(Config, "EmojiConfig")
local ShortConfig = T(Config, "ShortConfig")
local ChatHelper = T(World, "ChatHelper")

function M:init()
  self:initEvent()
  self.msgText = self:child("MsgText")
  self.textPageTag = self:child("TextPageTag")
  self.imageVoice = self:child("ImageVoice")
  self.itemWidth = self:getPixelSize().width
  self.textPageTag:setVisible(miniChatCfg.pageTagSwitch)
end

function M:initEvent()
end

function M:initData(msgData)
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
    self.userDetailInfoCancel = nil
  end
  self.msgData = msgData
  self.imageVoice:setVisible(false)
  local msgColor = self:getTextColor(msgData.pageType, msgData.fromId)
  local tagStr = self:getPageTagStr(msgData.pageType)
  local detailInfo = ChatHelper:getUserDetailInfo(msgData.fromId)
  if detailInfo then
    msgData.fromName = detailInfo.nickName or ""
  else
    self:listenDetailInfo(msgData.fromId, msgData.fromName)
  end
  self.textPageTag:setText(tagStr)
  local tagWidth = self.textPageTag:getWindowRenderer():getDocumentWidth()
  local msgWidth = self.itemWidth - tagWidth
  self.msgText:setWidth({0, msgWidth})
  self.msgText:setXPosition({0, tagWidth})
  if msgData.msgType == MsgType.Text then
    local fixMsg = self:fixShowMsg(msgData.msg)
    self.msgText:setText(msgColor .. string.format("%s:%s", msgData.fromName, fixMsg))
  elseif msgData.msgType == MsgType.Emoji then
    local data = EmojiConfig:getCfgById(tonumber(msgData.msg))
    if data then
      local fixMsg = self:fixShowMsg(Lang:toText(data.text))
      self.msgText:setText(msgColor .. string.format("%s:\227\128\144%s\227\128\145", msgData.fromName, fixMsg))
    end
  elseif msgData.msgType == MsgType.ShortMsg then
    local data = ShortConfig:getCfgById(tonumber(msgData.msg))
    if data then
      local fixMsg = self:fixShowMsg(Lang:toText(data.text))
      self.msgText:setText(msgColor .. string.format("%s:%s", msgData.fromName, fixMsg))
    end
  elseif msgData.msgType == MsgType.Voice then
    self.msgText:setText(msgColor .. string.format("%s:", msgData.fromName))
    local width = self.msgText:getWindowRenderer():getDocumentWidth()
    self.imageVoice:setVisible(true)
    self.imageVoice:setXPosition({
      0,
      tagWidth + width
    })
  end
  local height = self.msgText:getWindowRenderer():getDocumentHeight()
  self:setHeight({0, height})
end

function M:getTextColor(pageType, fromId)
  local color
  if fromId == Me.platformUserId then
    color = miniChatCfg.textColor.selfTextColor
  else
    color = miniChatCfg.textColor[pageType]
  end
  color = color or miniChatCfg.textColor.defaultTextColor
  return string.format("[colour='%s']", color)
end

function M:getPageTagStr(pageType)
  local tagConfig = miniChatCfg.pageTag[pageType]
  if tagConfig and miniChatCfg.pageTagSwitch then
    local color = tagConfig.color or "FFFFFFFF"
    return string.format("[colour='%s']\227\128\144%s\227\128\145", color, Lang:toText(tagConfig.name))
  end
  return ""
end

function M:fixShowMsg(str, len)
  if not miniChatCfg.textLimitChatSwitch then
    return str
  end
  len = len or miniChatCfg.textLimitChatLen
  local showMsg = len < Lib.getStringLen(str) and Lib.subString(str, len) .. "..." or str
  return showMsg
end

function M:listenDetailInfo(userId, fromName)
  if not userId then
    return
  end
  self.userDetailInfoCancel = Lib.lightSubscribeEvent("", "EVENT_USER_DETAIL" .. userId, function(data)
    self.msgText:setText(string.gsub(self.msgText:getText(), fromName, data.nickName, 1))
    if self.msgData.msgType == MsgType.Voice then
      local width = self.msgText:getWindowRenderer():getDocumentWidth()
      self.imageVoice:setXPosition({0, width})
    end
    if self.userDetailInfoCancel then
      self.userDetailInfoCancel()
    end
  end)
  ChatHelper:initDetailInfo(userId)
end

function M:onDestroy()
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
    self.userDetailInfoCancel = nil
  end
end

M:init()

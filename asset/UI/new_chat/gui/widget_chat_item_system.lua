local ChatHelper = T(World, "ChatHelper")

function M:init()
  self.data = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.textMsg = self.TextMsg
  self.textMsgInitW = self.textMsg:getWidth()[2]
  self.textMsgInitH = self.textMsg:getHeight()[2]
  self.rootHeightGap = self:getHeight()[2] - self.textMsg:getHeight()[2]
end

function M:initEvent()
end

function M:initData(msgData)
  if not msgData then
    return
  end
  self.data = msgData
  self:setMsgContent()
end

function M:setMsgContent()
  self:setTextWidget(self.textMsg, self.textMsgInitW, self.textMsgInitH)
  local textSize = self.textMsg:getSize()
  self:setHeight({
    0,
    textSize.height[2] + self.rootHeightGap
  })
end

function M:setTextWidget(textWidget, initW, initH)
  local msgText = self:getMsgText()
  textWidget:setHeight({0, initH})
  textWidget:setProperty("AutoScale", "1")
  textWidget:setProperty("HorzFormatting", "CentreAligned")
  textWidget:setText(msgText)
  if initW < textWidget:getWidth()[2] then
    textWidget:setProperty("AutoScale", "2")
    textWidget:setProperty("HorzFormatting", "WordWrapCentreAligned")
    textWidget:setWidth({0, initW})
    textWidget:setText(msgText)
  end
end

function M:getMsgText()
  return self.data.msg
end

M:init()

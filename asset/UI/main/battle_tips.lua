function M:onOpen(params)
  self:initUI()
end

function M:onClose(params)
end

function M:initUI()
end

function M:initItemData(itemInfo)
  self:setAlpha(1)
  if itemInfo.type == 1 then
    self:showFlyTipsInfo1(itemInfo)
  end
end

function M:showFlyTipsInfo1(itemInfo)
  local msg = itemInfo.content or ""
  self.tip_text:setText(msg)
end

function M:setCreateTime(createTime)
  self.createShowTime = createTime
end

function M:getCreateTime()
  return self.createShowTime or 0
end

function M:setStartActionTime(startTime)
  self.startActionTime = startTime
end

function M:getStartActionTime()
  return self.startActionTime or 0
end

function M:getItemYPosition()
  local pos = self:getPosition()
  return pos[2][2]
end

function M:setItemYPosition(posY)
  local pos = self:getPosition()
  local posX = pos[1][2]
  self:setPosition(UDim2.new(0, posX, 0, posY))
end

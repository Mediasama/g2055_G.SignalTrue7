local NumberWidth = 26
local NumberHeight = 29

function M:onOpen(params)
  self.numberImageList = {}
  self:initUI()
end

function M:onClose(params)
end

function M:initUI()
end

function M:makeTextUIGrid(text)
  local textList = {}
  for i = 1, #text do
    local word = text:sub(i, i)
    if word == "." then
      word = "f"
    end
    textList[i] = word
  end
  local len = #textList
  local widthSum = 0
  local maxHeight = 0
  self.numberImageList = {}
  local width, height
  local x = 0
  for i = 1, len do
    local ch = textList[i]
    local item = UI:createStaticImage("number" .. i)
    local imgFile = string.format("set:g2055_number_red.json image:%s", ch)
    item:setImage(imgFile)
    item:setSize(UDim2.new(0, NumberWidth, 0, NumberHeight))
    self.HorizontalLayout:addChild(item)
    local size = item:getSize()
    width = size.width[2]
    height = size.height[2]
    x = x + width
    table.insert(self.numberImageList, item)
  end
  return widthSum, maxHeight
end

function M:setScale(scale)
  local width = NumberWidth * scale
  local height = NumberHeight * scale
  for i, item in pairs(self.numberImageList) do
    item:setSize(UDim2.new(0, width, 0, height))
  end
end

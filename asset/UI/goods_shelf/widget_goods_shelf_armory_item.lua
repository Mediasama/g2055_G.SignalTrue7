local WidgetGoodsShelfArmoryItem = M

function WidgetGoodsShelfArmoryItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtId = self:child("TextID")
  self.txtPrice = self:child("TextPrice")
  self.imgCurrency = self:child("ImageCurrency")
end

function WidgetGoodsShelfArmoryItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetGoodsShelfArmoryItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetGoodsShelfArmoryItem:onClose()
  self.clickCallback = nil
end

function WidgetGoodsShelfArmoryItem:setData(data)
  self.index = data.index
  self.imgSelect:setVisible(data.selected)
  local itemData = data.value
  local imagePath = itemData.itemIcon
  self.imgIcon:setImage(imagePath)
  self.txtId:setText("")
  self.txtPrice:setText(tostring(itemData.price))
end

function WidgetGoodsShelfArmoryItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetGoodsShelfArmoryItem:getIndex()
  return self.index
end

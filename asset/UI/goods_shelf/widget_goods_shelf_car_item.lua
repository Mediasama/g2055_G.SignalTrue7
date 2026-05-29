local WidgetGoodsShelfCarItem = M

function WidgetGoodsShelfCarItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtId = self:child("TextID")
  self.txtPrice = self:child("TextPrice")
  self.imgCurrency = self:child("ImageCurrency")
end

function WidgetGoodsShelfCarItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetGoodsShelfCarItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetGoodsShelfCarItem:onClose()
  self.clickCallback = nil
end

function WidgetGoodsShelfCarItem:setData(data)
  self.index = data.index
  self.imgSelect:setVisible(data.selected)
  local itemData = data.value
  local imagePath = itemData.vehicle_icon
  self.imgIcon:setImage(imagePath)
  self.txtId:setText("")
  self.txtPrice:setText(tostring(itemData.vehicle_price))
end

function WidgetGoodsShelfCarItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetGoodsShelfCarItem:getIndex()
  return self.index
end

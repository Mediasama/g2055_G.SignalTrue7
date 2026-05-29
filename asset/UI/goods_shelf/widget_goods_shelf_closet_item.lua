local WidgetGoodsShelfClosetItem = M

function WidgetGoodsShelfClosetItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtId = self:child("TextID")
  self.txtPrice = self:child("TextPrice")
  self.txtPossess = self:child("TextPossess")
  self.imgCurrency = self:child("ImageCurrency")
  self.panelPrice = self:child("PricePanel")
  self.panelPossess = self:child("PossessPanel")
end

function WidgetGoodsShelfClosetItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetGoodsShelfClosetItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetGoodsShelfClosetItem:onClose()
  self.clickCallback = nil
end

function WidgetGoodsShelfClosetItem:setData(data)
  self.index = data.index
  self.imgSelect:setVisible(data.selected)
  local itemData = data.value
  local imagePath = itemData.iconBoy
  local sex = Me.userDetailData.sex or 1
  if sex ~= 1 then
    imagePath = itemData.iconGirl
  end
  self.imgIcon:setImage(imagePath)
  self.txtId:setText("")
  self.txtPrice:setText(tostring(itemData.price))
  self.txtPossess:setText(Lang:toText("goods_shelf.closet.already.possess"))
  local player = Me
  local ownItem = Me:getBastionClothesItem(itemData.id)
  if ownItem == nil then
    self.panelPrice:setVisible(true)
    self.panelPossess:setVisible(false)
  else
    self.panelPrice:setVisible(false)
    self.panelPossess:setVisible(true)
  end
end

function WidgetGoodsShelfClosetItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetGoodsShelfClosetItem:getIndex()
  return self.index
end

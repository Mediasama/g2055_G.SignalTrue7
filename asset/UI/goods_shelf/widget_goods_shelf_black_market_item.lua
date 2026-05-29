local WidgetGoodsShelfBlackMarketItem = M

function WidgetGoodsShelfBlackMarketItem:initUI()
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

function WidgetGoodsShelfBlackMarketItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetGoodsShelfBlackMarketItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetGoodsShelfBlackMarketItem:onClose()
  self.clickCallback = nil
end

function WidgetGoodsShelfBlackMarketItem:setData(data)
  self.index = data.index
  self.imgSelect:setVisible(data.selected)
  local itemData = data.value
  self.imgIcon:setImage(itemData.icon)
  self.txtId:setText("")
  self.txtPrice:setText(tostring(itemData.price))
  self.txtPossess:setText(Lang:toText("goods_shelf.closet.already.possess"))
  local alreadyOwned = true
  if itemData then
    local goodsList = itemData.goods or {}
    for i, goods in pairs(goodsList) do
      if goods.type == Define.GoodsShelf.Type.Clothes then
        local ownItem = Me:getBastionClothesItem(goods.id)
        if ownItem == nil then
          alreadyOwned = false
        end
      else
        alreadyOwned = false
      end
    end
  end
  if alreadyOwned then
    self.panelPrice:setVisible(false)
    self.panelPossess:setVisible(true)
  else
    self.panelPrice:setVisible(true)
    self.panelPossess:setVisible(false)
  end
end

function WidgetGoodsShelfBlackMarketItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetGoodsShelfBlackMarketItem:getIndex()
  return self.index
end

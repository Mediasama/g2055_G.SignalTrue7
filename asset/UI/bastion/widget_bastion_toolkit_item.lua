local WidgetBastionToolkitItem = M

function WidgetBastionToolkitItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtNormal = self:child("TextNormal")
  self.txtSelect = self:child("TextSelect")
end

function WidgetBastionToolkitItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetBastionToolkitItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetBastionToolkitItem:onClose()
  self.clickCallback = nil
end

function WidgetBastionToolkitItem:setData(data)
  self.index = data.index
  local itemData = data.value
  self.imgIcon:setImage(itemData.icon)
  self.txtNormal:setText(tostring(itemData.price))
  self.txtSelect:setText(tostring(itemData.price))
  self.imgSelect:setVisible(data.selected)
  self.txtNormal:setVisible(not data.selected)
  self.txtSelect:setVisible(data.selected)
end

function WidgetBastionToolkitItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetBastionToolkitItem:getIndex()
  return self.index
end

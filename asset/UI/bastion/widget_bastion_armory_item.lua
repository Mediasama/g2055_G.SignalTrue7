local WidgetBastionArmoryItem = M

function WidgetBastionArmoryItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.imgBullet = self:child("ImageBullet")
  self.txtId = self:child("TextID")
  self.txtBullet = self:child("TextIBullet")
end

function WidgetBastionArmoryItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetBastionArmoryItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetBastionArmoryItem:onClose()
  self.clickCallback = nil
end

function WidgetBastionArmoryItem:setData(data)
  self.index = data.index
  self.imgSelect:setVisible(data.selected)
  local config = data.config
  self.imgIcon:setImage(config.itemIcon)
  self.txtBullet:setText(data.bulletCount)
  self.txtBullet:setVisible(config.weaponType ~= 1)
  self.imgBullet:setVisible(config.weaponType ~= 1)
  self.txtId:setText("")
end

function WidgetBastionArmoryItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetBastionArmoryItem:getIndex()
  return self.index
end

local WidgetBastionHandbagItem = M

function WidgetBastionHandbagItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtId = self:child("TextID")
  self.txtId = self:child("TextID")
  self.imgBullet = self:child("ImageBullet")
  self.txtBullet = self:child("TextIBullet")
end

function WidgetBastionHandbagItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetBastionHandbagItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetBastionHandbagItem:onClose()
  self.clickCallback = nil
end

function WidgetBastionHandbagItem:setData(data)
  self.index = data.index
  self.imgSelect:setVisible(data.selected)
  self.txtId:setText("")
  self.txtBullet:setText(data.bulletCount)
  local config = data.config
  if config then
    self.imgIcon:setVisible(true)
    self.imgIcon:setImage(config.longItemIcon)
    self.txtBullet:setVisible(config.weaponType ~= 1)
    self.imgBullet:setVisible(config.weaponType ~= 1)
  else
    self.imgIcon:setVisible(false)
    self.txtBullet:setVisible(false)
    self.imgBullet:setVisible(false)
  end
end

function WidgetBastionHandbagItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetBastionHandbagItem:getIndex()
  return self.index
end

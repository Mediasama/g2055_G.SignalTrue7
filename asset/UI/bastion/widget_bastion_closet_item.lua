local WidgetBastionClosetItem = M

function WidgetBastionClosetItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtId = self:child("TextID")
end

function WidgetBastionClosetItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetBastionClosetItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetBastionClosetItem:onClose()
  self.clickCallback = nil
end

function WidgetBastionClosetItem:setData(data)
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
end

function WidgetBastionClosetItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetBastionClosetItem:getIndex()
  return self.index
end

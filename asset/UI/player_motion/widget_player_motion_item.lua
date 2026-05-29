local WidgetPlayerMotionItem = M

function WidgetPlayerMotionItem:initUI()
  self.clickCallback = nil
  self.btnTrigger = self:child("ImageTrigger")
  self.imgSelect = self:child("ImageSelect")
  self.imgIcon = self:child("ImageIcon")
  self.txtName = self:child("TextName")
  self.imageSelectPaid = self:child("ImageSelectPaid")
  self.imageLock = self:child("ImageLock")
end

function WidgetPlayerMotionItem:initEvent()
  function self.btnTrigger.onMouseClick()
    if self.clickCallback then
      self.clickCallback(self)
    end
  end
end

function WidgetPlayerMotionItem:onOpen()
  self:initUI()
  self:initEvent()
end

function WidgetPlayerMotionItem:onClose()
  self.clickCallback = nil
end

function WidgetPlayerMotionItem:setData(data)
  self.index = data.index
  local config = data.configItem or {}
  local selected = data.selected or false
  self.txtName:setText(Lang:toText(config.name))
  self.ifPaidMotion = config.ifPaidMotion
  self.imageSelectPaid:setVisible(self.ifPaidMotion)
  self.imgSelect:setVisible(not self.ifPaidMotion)
  self.isLock = self.ifPaidMotion and not Me:checkPlayerMotionPaid(config.id)
  self.imageLock:setVisible(self.isLock)
end

function WidgetPlayerMotionItem:setClickCallback(callback)
  self.clickCallback = callback
end

function WidgetPlayerMotionItem:getIndex()
  return self.index
end

function WidgetPlayerMotionItem:getIsPaid()
  return self.ifPaidMotion
end

function WidgetPlayerMotionItem:getIsLock()
  return self.isLock
end

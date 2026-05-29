local GangIconConfig = T(Config, "GangIconConfig")

function M:init()
  self.buttonImageIcon = self:child("ButtonImageIcon")
  self.imageSelected = self:child("ImageSelected")
  self.imageIcon = self:child("ImageIcon")
  
  function self.buttonImageIcon.onMouseClick()
    if self.itemClickCb then
      self.itemClickCb(self.data)
    end
  end
end

function M:onDataChanged(data)
  self.index = data.index
  self.data = data.data
  self.imageSelected:setVisible(data.selected)
  self.itemClickCb = data.itemClickCb
  local icon = GangIconConfig:getGangCreateIcon(self.data.id)
  self.imageIcon:setImage(icon)
end

function M:onOpen()
  self:init()
end

function M:destroy()
end

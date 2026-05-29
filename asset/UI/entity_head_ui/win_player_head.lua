local GangIconConfig = T(Config, "GangIconConfig")
local colorRed = Color3.new(1, 0, 0)
local colorGreen = Color3.new(0, 1, 0)

function M:init()
  self:initUI()
  self:initEvent()
end

function M:initData()
end

function M:initUI()
  self.imageGangIcon = self:child("ImageGangIcon")
  self.imageGangIcon:setVisible(false)
  self.textGangName = self:child("TextGangName")
  self.panel = self:child("Panel")
end

function M:onOpen(param)
  self:init()
  self.objID = param.objID
end

function M:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REFRESH_PLAYER_GANG_ICON, function(objID, data)
    if objID ~= self.objID then
      return
    end
    if data == nil or data.id == nil then
      self.imageGangIcon:setVisible(false)
    else
      self.imageGangIcon:setVisible(true)
      local icon = GangIconConfig:getGangCreateIcon(data.id)
      if icon then
        self.imageGangIcon:setImage(icon)
      end
      self.textGangName:setText(data.name)
      if Me:isMyGang(data.gangId) then
        self.textGangName:setTextColours(colorGreen)
      else
        self.textGangName:setTextColours(colorRed)
      end
      local pos = self.imageGangIcon:getPosition()
      pos[1][2] = (self.panel:getPixelSize().width - self.textGangName:getArea().max[1][2]) / 2
      self.imageGangIcon:setPosition(pos)
    end
  end)
end

function M:close()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function M:init()
  self:initUI()
  
  self:initEvent()
end

function M:initUI()
  self:child("TextYellow"):setText(Lang:toText("gang.circle.tips.yellow"))
  self:child("TextRed"):setText(Lang:toText("gang.circle.tips.red"))
  self:updateTips()
  self.isHide = false
end

function M:updateTips()
  self:child("TextGreen"):setText(Lang:toText(Me.gang and "gang.circle.tips.green" or "gang.circle.tips.no.gang"))
end

function M:initEvent()
  self:child("PanelTouch").onMouseClick = function()
    self.isHide = not self.isHide
    self:setXPosition({
      0,
      self.isHide and -(self:getPixelSize().width - 40) or 0
    })
  end
  Lib.subscribeEvent(Event.EVENT_REFRESH_GANG_VIEW, function()
    self:updateTips()
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_GANG, function()
    self:updateTips()
  end)
end

M:init()

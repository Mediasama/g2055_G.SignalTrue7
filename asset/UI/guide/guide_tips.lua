function M:onOpen(params)
  self:hideWin()
  
  self:initUIControl()
end

function M:hideWin()
  self.tipsWindow:setVisible(false)
end

function M:hideTipsWin()
  self.tipsWindow:setVisible(false)
end

function M:showTipsWin(str, pos)
  self.tipsWindow:setVisible(true)
  local msg = Lang:toText(str)
  self.tipsWindow.guide_text:setText(msg)
  self.tipsWindow:setPosition(UDim2.new(0, pos[1], 0, pos[2]))
end

function M:initUIControl()
end

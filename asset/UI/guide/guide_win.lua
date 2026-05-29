function M:onOpen(params)
  self:hideWin()
  
  self:initUIControl()
end

function M:hideWin()
  self.topWindow:setVisible(false)
end

function M:showTopWin(str)
  self.topWindow:setVisible(true)
  local msg = Lang:toText(str)
  self.topWindow.guide_text:setText(msg)
end

function M:initUIControl()
end

function M:init()
  self.cbTarget = nil
  
  self.cbFunc = nil
  self.cbParam = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.btnClose = self:child("ButtonClose")
  self.btnConfirm = self:child("ButtonConfirm")
  self.btnCancel = self:child("ButtonCancel")
  self.btnConfirm:setText(Lang:toText("passCard.yes"))
  self.btnCancel:setText(Lang:toText("passCard.no"))
end

function M:initEvent()
  function self.btnClose.onMouseClick()
    self:close()
  end
  
  function self.btnCancel.onMouseClick()
    self:close()
  end
  
  function self.btnConfirm.onMouseClick()
    if self.cbFunc then
      self.cbFunc(self.cbTarget, table.unpack(self.cbParam))
      self:close()
    end
  end
end

function M:setDetail(detailStr)
  if detailStr then
    self:child("TextDetail"):setText(detailStr)
  end
end

function M:setCallBack(target, func, ...)
  self.cbTarget = target
  self.cbFunc = func
  self.cbParam = table.pack(...)
end

M:init()

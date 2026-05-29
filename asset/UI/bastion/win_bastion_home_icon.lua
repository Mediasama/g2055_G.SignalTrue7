local WinBastionHomeIcon = M

function WinBastionHomeIcon:initUI()
end

function WinBastionHomeIcon:initEvent()
  self._allEvent = {}
end

function WinBastionHomeIcon:initView(param)
  self.info = param
end

function WinBastionHomeIcon:updateView(objID, data)
  if not self.isValid then
    return
  end
  if not self.info then
    return
  end
end

function WinBastionHomeIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionHomeIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinBastionHomeIcon

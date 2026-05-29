local WinBastionClosetIcon = M

function WinBastionClosetIcon:initUI()
  self.panelOwner = self:child("PanelOwner")
  self.panelStealer = self:child("PanelStealer")
  self.btnFetch = self:child("ButtonFetch")
  self.btnSteal = self:child("ButtonSteal")
  self:child("TextFetch"):setText(Lang:toText("name.house.7"))
  self:child("TextSteal"):setText(Lang:toText("name.house.7"))
end

function WinBastionClosetIcon:initEvent()
  function self.btnFetch.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Fetch)
  end
  
  function self.btnSteal.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Steal)
  end
end

function WinBastionClosetIcon:initView(param)
  self.info = param
  self:updateView()
end

function WinBastionClosetIcon:updateView()
  local isMyVault = Me.platformUserId == self.info.ownerId
  self.panelOwner:setVisible(isMyVault)
  self.panelStealer:setVisible(not isMyVault)
end

function WinBastionClosetIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionClosetIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionClosetIcon:openOperateUI(manner)
  Me:playSoundByKey("g2055_commonButtonSound")
  local param = Lib.copy(self.info)
  param.manner = manner
  local windowKey = (manner or "Unknown") .. (param.ownerId or "unknown")
  UI:openCustomWindow("./UI/bastion/win_bastion_closet", windowKey, param)
end

return WinBastionClosetIcon

local WinBastionVaultIcon = M

function WinBastionVaultIcon:initUI()
  self.panelOwner = self:child("PanelOwner")
  self.panelStealer = self:child("PanelStealer")
  self.btnDeposit = self:child("ButtonDeposit")
  self.btnFetch = self:child("ButtonFetch")
  self.btnSteal = self:child("ButtonSteal")
  self:child("TextDeposit"):setText(Lang:toText("name.house.4"))
  self:child("TextFetch"):setText(Lang:toText("name.house.5"))
  self:child("TextSteal"):setText(Lang:toText("name.house.5"))
end

function WinBastionVaultIcon:initEvent()
  function self.btnDeposit.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Deposit)
  end
  
  function self.btnFetch.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Fetch)
  end
  
  function self.btnSteal.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Steal)
  end
end

function WinBastionVaultIcon:initView(param)
  self.info = param
  self:updateView()
end

function WinBastionVaultIcon:updateView()
  local isMyVault = Me.platformUserId == self.info.ownerId
  self.panelOwner:setVisible(isMyVault)
  self.panelStealer:setVisible(not isMyVault)
end

function WinBastionVaultIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionVaultIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionVaultIcon:openOperateUI(manner)
  Me:playSoundByKey("g2055_commonButtonSound")
  local param = Lib.copy(self.info)
  param.manner = manner
  local windowKey = (param.manner or "Vault") .. (param.ownerId or "unknown")
  UI:openCustomWindow("./UI/bastion/win_bastion_vault", windowKey, param)
end

return WinBastionVaultIcon

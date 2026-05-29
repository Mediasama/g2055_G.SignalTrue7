local WinBastionArmoryIcon = M

function WinBastionArmoryIcon:initUI()
  self.panelOwner = self:child("PanelOwner")
  self.panelStealer = self:child("PanelStealer")
  self.btnFetch = self:child("ButtonFetch")
  self.btnSteal = self:child("ButtonSteal")
  self:child("TextFetch"):setText(Lang:toText("name.house.6"))
  self:child("TextSteal"):setText(Lang:toText("name.house.6"))
end

function WinBastionArmoryIcon:initEvent()
  function self.btnFetch.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Fetch)
  end
  
  function self.btnSteal.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Steal)
  end
end

function WinBastionArmoryIcon:initView(param)
  self.info = param
  self:updateView()
  self:reload()
end

function WinBastionArmoryIcon:updateView(data)
  if not self.isValid then
    return
  end
  self.panelOwner:setVisible(false)
  self.panelStealer:setVisible(false)
  if not data then
    return
  end
  local level = data.level or 0
  if level <= 0 then
    self.panelOwner:setVisible(false)
    self.panelStealer:setVisible(false)
  else
    local isMyVault = Me.platformUserId == self.info.ownerId
    self.panelOwner:setVisible(isMyVault)
    self.panelStealer:setVisible(not isMyVault)
  end
end

function WinBastionArmoryIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionArmoryIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionArmoryIcon:reload()
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Query
  param.operatorId = Me.platformUserId
  player:C2S_OperateBastionFacility(param, function(param)
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local data = rsp.data or {}
      self:updateView(data)
    else
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

function WinBastionArmoryIcon:openOperateUI(manner)
  Me:playSoundByKey("g2055_commonButtonSound")
  local param = Lib.copy(self.info)
  param.manner = manner
  local windowKey = (manner or "Unknown") .. (param.ownerId or "unknown")
  UI:openCustomWindow("./UI/bastion/win_bastion_armory", windowKey, param)
end

return WinBastionArmoryIcon

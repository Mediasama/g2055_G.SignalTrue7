local WinBastionGarageIcon = M

function WinBastionGarageIcon:initUI()
  self.panelOwner = self:child("PanelOwner")
  self.panelBuy = self:child("PanelBuy")
  self.panelFetch = self:child("PanelFetch")
  self.panelStealer = self:child("PanelStealer")
  self.btnBuy = self:child("ButtonBuy")
  self.txtPrice = self:child("TextPrice")
  self.btnFetch = self:child("ButtonFetch")
  self.btnSteal = self:child("ButtonSteal")
  self:child("TextFetch"):setText(Lang:toText("name.house.8"))
  self:child("TextSteal"):setText(Lang:toText("name.house.8"))
  local config = World.cfg.bastionSetting or {}
  local garage = config.garage or {}
  local unlockPrice = garage.unlockPrice or 100
  self.txtPrice:setText(unlockPrice)
end

function WinBastionGarageIcon:initEvent()
  function self.btnBuy.onMouseClick()
    self:requestOperate(Define.Bastion.Facility.OperateType.Buy)
  end
  
  function self.btnFetch.onMouseClick()
    local selectCarIndex = self:getSelectCarIndex()
    self:requestOperate(Define.Bastion.Facility.OperateType.Fetch, selectCarIndex)
  end
  
  function self.btnSteal.onMouseClick()
    local selectCarIndex = self:getSelectCarIndex()
    self:requestOperate(Define.Bastion.Facility.OperateType.Steal, selectCarIndex)
  end
end

function WinBastionGarageIcon:initView(param)
  self.info = param
  self:updateView(nil)
  self:reload()
end

function WinBastionGarageIcon:updateView(data)
  if not self.isValid then
    return
  end
  self.panelOwner:setVisible(false)
  self.panelStealer:setVisible(false)
  if not data then
    return
  end
  self.data = data
  local level = data.level or 0
  if level <= 0 then
    self.panelBuy:setVisible(false)
    self.panelFetch:setVisible(false)
  else
    self.panelBuy:setVisible(false)
    self.panelFetch:setVisible(true)
    local isMyVault = Me.platformUserId == self.info.ownerId
    self.panelOwner:setVisible(isMyVault)
    self.panelStealer:setVisible(not isMyVault)
  end
end

function WinBastionGarageIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionGarageIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionGarageIcon:getSelectCarIndex()
  return 1
end

function WinBastionGarageIcon:reload()
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

function WinBastionGarageIcon:openGarageGuide()
  UI:openCustomWindow("./UI/bastion/win_bastion_garage_guide")
end

function WinBastionGarageIcon:requestOperate(manner, selectCarIndex)
  Me:playSoundByKey("g2055_commonButtonSound")
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.manner = manner
  param.requestData = {index = selectCarIndex}
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local data = rsp.data or {}
      self:updateView(data)
      if manner == Define.Bastion.Facility.OperateType.Buy then
        Me:playSoundByKey("g2055_rebuildSound")
      end
    else
      if rsp.status == Define.Bastion.Facility.OperateErrorCode.Failed then
        local msg = Lang:toText(rsp.msg or "")
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      end
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

return WinBastionGarageIcon

local WinBastionDoorSensorIcon = M

function WinBastionDoorSensorIcon:initUI()
  self.panelOwner = self:child("PanelOwner")
  self.panelStealer = self:child("PanelStealer")
  self.btnFetch = self:child("ButtonFetch")
  self.btnSteal = self:child("ButtonSteal")
  self.txtAmount = self:child("TextAmount")
  self.progressBar = self:child("ProgressBar")
  self.txtProgress = self:child("TextProgress")
  self.txtProgress:setText(Lang:toText("bastion.door.unlocking"))
  self.progressBar:setVisible(false)
  self:child("Text"):setText(Lang:toText("bastion.door.text.unlock"))
  self.imageBG = self:child("ImageBG")
end

function WinBastionDoorSensorIcon:initEvent()
  function self.btnFetch.onMouseClick()
  end
  
  function self.btnSteal.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:requestHack()
  end
  
  function self.imageBG.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:requestHack()
  end
end

function WinBastionDoorSensorIcon:initView(param)
  self.info = param
  self:updateView({})
  self:reload()
  self:setLevel(1)
end

function WinBastionDoorSensorIcon:updateView(data)
  if not self.isValid then
    return
  end
  local isMyVault = Me.platformUserId == self.info.ownerId
  self.panelOwner:setVisible(false)
  self.panelStealer:setVisible(not isMyVault)
  self.progressBar:setVisible(false)
  if isMyVault then
    self.txtAmount:setText("amount")
  else
    local amount = Me:getCostItemCountByItemID(Define.Bastion.DoorHackItemID) or 0
    self.txtAmount:setText(amount)
  end
  local status = Define.Bastion.Defense.Status.None
  if data and data.property and data.property.status then
    status = data.property.status
  end
  if status == Define.Bastion.Defense.Status.Normal then
    self.btnFetch:setVisible(false)
    self.btnSteal:setVisible(true)
    self.imageBG:setVisible(true)
  else
    self.btnFetch:setVisible(false)
    self.btnSteal:setVisible(false)
    self.imageBG:setVisible(false)
  end
end

function WinBastionDoorSensorIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionDoorSensorIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionDoorSensorIcon:reload()
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Query
  param.operatorId = Me.platformUserId
  param.triggerParam = nil
  param.requestData = {
    type = Define.Bastion.Defense.Type.Door
  }
  player:C2S_OperateBastionFacility(param, function(param)
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local data = rsp.data or {}
      self:updateView(data)
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionDoorSensorIcon:requestHack()
  if self.waitResponse then
    return
  end
  local hackObjID = Me:bhp_getHackObjID()
  if 0 < hackObjID then
    return
  end
  self.waitResponse = true
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.manner = Define.Bastion.Facility.OperateType.Steal
  param.requestData = {
    type = Define.Bastion.Defense.Type.Door
  }
  local player = Me
  Blockman.instance:control().enable = false
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local data = rsp.data or {}
      self:updateView(data)
    else
      Blockman.instance:control().enable = true
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

return WinBastionDoorSensorIcon

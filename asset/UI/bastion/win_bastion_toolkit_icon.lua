local WinBastionToolkitIcon = M

function WinBastionToolkitIcon:initUI()
  self.panelOwner = self:child("PanelOwner")
  self.panelStealer = self:child("PanelStealer")
  self.panelGarage = self:child("PanelBuyGarage")
  self.panelArmory = self:child("PanelBuyArmory")
  self.txtGaragePrice = self:child("TextPriceGarage")
  self.txtGarageArmory = self:child("TextPriceArmory")
  self.btnBuyGarage = self:child("ButtonBuyGarage")
  self.btnBuyArmory = self:child("ButtonBuyArmory")
  self.btnFetch = self:child("ButtonFetch")
  self.btnSteal = self:child("ButtonSteal")
  self:child("TextGarage"):setText(Lang:toText("name.house.2"))
  self:child("TextArmory"):setText(Lang:toText("name.house.1"))
  self:child("TextFetch"):setText(Lang:toText("name.house.3"))
  local config = World.cfg.bastionSetting or {}
  local garage = config.garage or {}
  local unlockGaragePrice = garage.unlockPrice or 100
  self.txtGaragePrice:setText(unlockGaragePrice)
  local armory = config.armory or {}
  local unlockArmoryPrice = armory.unlockPrice or 100
  self.txtGarageArmory:setText(unlockArmoryPrice)
end

function WinBastionToolkitIcon:initEvent()
  function self.btnFetch.onMouseClick()
    self:openOperateUI(Define.Bastion.Facility.OperateType.Fetch)
  end
  
  function self.btnBuyGarage.onMouseClick()
    self:requestBuyGarage()
  end
  
  function self.btnBuyArmory.onMouseClick()
    self:requestBuyArmory()
  end
end

function WinBastionToolkitIcon:initView(param)
  self.info = param
  self:updateView()
end

function WinBastionToolkitIcon:updateView()
  if not self.isValid then
    return
  end
  local isMyVault = Me.platformUserId == self.info.ownerId
  self.panelOwner:setVisible(isMyVault)
  self.panelStealer:setVisible(not isMyVault)
  local iconCount = 1
  local garageLevel = Me:getBastionGarageLevel()
  self.panelGarage:setVisible(garageLevel <= 0)
  if garageLevel <= 0 then
    iconCount = iconCount + 1
  end
  local armoryLevel = Me:getBastionArmoryLevel()
  self.panelArmory:setVisible(armoryLevel <= 0)
  if armoryLevel <= 0 then
    iconCount = iconCount + 1
  end
  local offsetY = 100
  if iconCount == 3 then
    local posGarage = self.panelGarage:getPosition()
    posGarage[2][2] = -offsetY
    self.panelGarage:setPosition(posGarage)
    local posArmory = self.panelArmory:getPosition()
    posArmory[2][2] = 0
    self.panelArmory:setPosition(posArmory)
    local posFetch = self.btnFetch:getPosition()
    posFetch[2][2] = offsetY
    self.btnFetch:setPosition(posFetch)
  elseif iconCount == 2 then
    local posGarage = self.panelGarage:getPosition()
    posGarage[2][2] = -offsetY / 2
    self.panelGarage:setPosition(posGarage)
    local posArmory = self.panelArmory:getPosition()
    posArmory[2][2] = -offsetY / 2
    self.panelArmory:setPosition(posArmory)
    local posFetch = self.btnFetch:getPosition()
    posFetch[2][2] = offsetY / 2
    self.btnFetch:setPosition(posFetch)
  else
    local posGarage = self.panelGarage:getPosition()
    posGarage[2][2] = 0
    self.panelGarage:setPosition(posGarage)
    local posArmory = self.panelArmory:getPosition()
    posArmory[2][2] = 0
    self.panelArmory:setPosition(posArmory)
    local posFetch = self.btnFetch:getPosition()
    posFetch[2][2] = 0
    self.btnFetch:setPosition(posFetch)
  end
end

function WinBastionToolkitIcon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionToolkitIcon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionToolkitIcon:openToolKitGuide()
  UI:openCustomWindow("./UI/bastion/win_bastion_toolkit_guide")
end

function WinBastionToolkitIcon:openOperateUI(manner)
  Me:playSoundByKey("g2055_commonButtonSound")
  local param = Lib.copy(self.info)
  param.manner = manner
  local windowKey = (manner or "Unknown") .. (param.ownerId or "unknown")
  UI:openCustomWindow("./UI/bastion/win_bastion_toolkit", windowKey, param)
end

function WinBastionToolkitIcon:getSelectCarIndex()
  return 1
end

function WinBastionToolkitIcon:requestBuyGarage()
  Me:playSoundByKey("g2055_commonButtonSound")
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.manner = Define.Bastion.Facility.OperateType.Buy
  param.type = Define.Bastion.Facility.Type.Garage
  param.requestData = {
    index = self:getSelectCarIndex()
  }
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:updateView()
      Me:playSoundByKey("g2055_rebuildSound")
    else
      if rsp.status == Define.Bastion.Facility.OperateErrorCode.Failed then
        local msg = Lang:toText(rsp.msg or "")
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      end
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

function WinBastionToolkitIcon:requestBuyArmory()
  Me:playSoundByKey("g2055_commonButtonSound")
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.manner = Define.Bastion.Facility.OperateType.Buy
  param.type = Define.Bastion.Facility.Type.Armory
  param.requestData = {
    index = self:getSelectCarIndex()
  }
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:updateView()
      Me:playSoundByKey("g2055_rebuildSound")
      Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_UNLOCK_WEAPON)
    else
      if rsp.status == Define.Bastion.Facility.OperateErrorCode.Failed then
        local msg = Lang:toText(rsp.msg or "")
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      end
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

return WinBastionToolkitIcon

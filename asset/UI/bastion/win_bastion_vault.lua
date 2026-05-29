local WinBastionVault = M

function WinBastionVault:initUI()
  self.btnClose = self:child("ButtonClose")
  self.imgIcon1 = self:child("ImageIcon1")
  self.imgIcon2 = self:child("ImageIcon2")
  self.txtAmount1 = self:child("TextAmount1")
  self.txtAmount2 = self:child("TextAmount2")
  self.sliderAmount = self:child("SliderAmount")
  local thumb = self.sliderAmount:getThumb()
  thumb:setClippedByParent(false)
  thumb:setWidth({0, 19})
  thumb:setHeight({0, 50})
  self.btnConfirm = self:child("ButtonConfirm")
end

function WinBastionVault:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  function self.sliderAmount.onSliderValueChanged(instance)
    self:updateView()
  end
  
  function self.btnConfirm.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    local balance = self.data.balance or 0
    local cash = self.data.cash or 0
    local requestData = {}
    if self.info.manner == Define.Bastion.Facility.OperateType.Deposit then
      local data = requestData
      data.delta = math.floor(cash * self.sliderAmount:getCurrentValue() / self.sliderAmount:getMaxValue())
      Lib.emitEvent(Event.EVENT_GUIDE_CLOSE_TIPS, Define.GUIDE_TIPS_PUT_MONEY)
      Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_PUT_MONEY)
    elseif self.info.manner == Define.Bastion.Facility.OperateType.Fetch then
      local data = requestData
      data.delta = math.floor(balance * self.sliderAmount:getCurrentValue() / self.sliderAmount:getMaxValue())
    elseif self.info.manner == Define.Bastion.Facility.OperateType.Steal then
      local data = requestData
      data.delta = math.floor(balance * self.sliderAmount:getCurrentValue() / self.sliderAmount:getMaxValue())
    end
    self:requestOperate(requestData)
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinBastionVault:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  local balanceIcon = "gameres|asset/Imageset/g2055_icon:icon_0_cashbox"
  local cashIcon = "gameres|asset/Imageset/g2055_icon:icon_0_savemoney"
  local stealIcon = "gameres|asset/Imageset/g2055_icon:icon_0_stealmoney"
  if self.info.manner == Define.Bastion.Facility.OperateType.Deposit then
    self.imgIcon1:setImage(cashIcon)
    self.imgIcon2:setImage(balanceIcon)
    self.btnConfirm:setText(Lang:toText("bastion.vault.manner.deposit"))
    Lib.emitEvent(Event.EVENT_GUIDE_OPEN_TIPS, Define.GUIDE_TIPS_PUT_MONEY)
  elseif self.info.manner == Define.Bastion.Facility.OperateType.Fetch then
    self.imgIcon1:setImage(balanceIcon)
    self.imgIcon2:setImage(cashIcon)
    self.btnConfirm:setText(Lang:toText("bastion.vault.manner.fetch"))
  elseif self.info.manner == Define.Bastion.Facility.OperateType.Steal then
    self.imgIcon1:setImage(balanceIcon)
    self.imgIcon2:setImage(stealIcon)
    self.btnConfirm:setText(Lang:toText("bastion.vault.manner.steal"))
  end
  self.data = {}
  self.waitResponse = false
  self:updateData(nil)
  self:reload()
end

function WinBastionVault:updateView()
  local balance = self.data.balance or 0
  local cash = self.data.cash or 0
  if self.info.manner == Define.Bastion.Facility.OperateType.Deposit then
    local delta = math.floor(cash * self.sliderAmount:getCurrentValue() / self.sliderAmount:getMaxValue())
    local remindAmount = cash - delta
    self.txtAmount1:setText(tostring(remindAmount))
    self.txtAmount2:setText(tostring(balance + delta))
    self.sliderAmount:setEnabled(0 < cash)
    if 0 < delta then
      self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
      self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
    else
      self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
      self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
    end
  elseif self.info.manner == Define.Bastion.Facility.OperateType.Fetch then
    local delta = math.floor(balance * self.sliderAmount:getCurrentValue() / self.sliderAmount:getMaxValue())
    local remindAmount = balance - delta
    self.txtAmount1:setText(tostring(remindAmount))
    self.txtAmount2:setText(tostring(cash + delta))
    self.sliderAmount:setEnabled(0 < balance)
    if 0 < delta then
      self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
      self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
    else
      self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
      self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
    end
  elseif self.info.manner == Define.Bastion.Facility.OperateType.Steal then
    local delta = math.floor(balance * self.sliderAmount:getCurrentValue() / self.sliderAmount:getMaxValue())
    local remindAmount = balance - delta
    self.txtAmount1:setText(tostring(remindAmount))
    self.txtAmount2:setText(tostring(cash + delta))
    self.sliderAmount:setEnabled(0 < balance)
    if 0 < delta then
      self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
      self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
    else
      self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
      self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
    end
  end
end

function WinBastionVault:updateData(data)
  if not self.isValid then
    return
  end
  self.data = data or {}
  self.sliderAmount:setCurrentValue(0)
  self.sliderAmount:setEnabled(false)
  self:updateView()
end

function WinBastionVault:reload()
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Query
  param.operatorId = Me.platformUserId
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local data = rsp.data
      self:updateData(data)
    else
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

function WinBastionVault:requestOperate(requestData)
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.requestData = requestData
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local data = rsp.data
      self:updateData(data)
      if rsp.status == Define.Bastion.Facility.OperateErrorCode.Overflow then
        local msg = Lang:toText(rsp.msg or "")
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      end
      Me:playSoundByKey("g2055_saveMoneySound")
      self:close()
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionVault:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionVault:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
  Lib.emitEvent(Event.EVENT_GUIDE_CLOSE_TIPS, Define.GUIDE_TIPS_PUT_MONEY)
  Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_PUT_MONEY)
end

return WinBastionVault

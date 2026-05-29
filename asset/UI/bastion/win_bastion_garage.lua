local WinBastionGarage = M

function WinBastionGarage:initUI()
  self.txtTitle = self:child("TextTitle")
  self.txtDetail = self:child("TextDetail")
  self.btnClose = self:child("ButtonClose")
  self.btnCancel = self:child("ButtonCancel")
  self.btnConfirm = self:child("ButtonConfirm")
end

function WinBastionGarage:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  function self.btnCancel.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:close()
  end
  
  function self.btnConfirm.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    local useCarInfo = Me:getInUseCar()
    if not useCarInfo then
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "bastion.garage.deposit.error.no.car")
      return
    end
    local carId = useCarInfo.id
    if not carId then
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "bastion.garage.deposit.error.no.car")
      return
    end
    self:requestOperate(1, carId)
    self:close()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinBastionGarage:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self:updateView({})
end

function WinBastionGarage:getManner()
  return self.info.manner
end

function WinBastionGarage:updateView(param)
  self.txtTitle:setText(Lang:toText("bastion.garage.deposit.dialog.title"))
  self.txtDetail:setText(Lang:toText("bastion.garage.deposit.dialog.detail"))
  self.btnCancel:setText(Lang:toText("bastion.garage.deposit.dialog.cancel"))
  self.btnConfirm:setText(Lang:toText("bastion.garage.deposit.dialog.confirm"))
end

function WinBastionGarage:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionGarage:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
end

function WinBastionGarage:requestOperate(index, id)
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.manner = Define.Bastion.Facility.OperateType.Deposit
  param.requestData = {index = index, id = id}
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
    else
      if rsp.status == Define.Bastion.Facility.OperateErrorCode.Failed then
        local msg = Lang:toText(rsp.msg or "")
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      end
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

return WinBastionGarage

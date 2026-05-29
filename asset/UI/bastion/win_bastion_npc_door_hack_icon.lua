local WinBastionNpcDoorHackIcon = M

function WinBastionNpcDoorHackIcon:initUI()
  self.btnSteal = self:child("ButtonSteal")
  self.txtAmount = self:child("TextAmount")
end

function WinBastionNpcDoorHackIcon:initEvent()
  function self.btnSteal.onMouseClick()
    self:requestHack()
  end
end

function WinBastionNpcDoorHackIcon:initView(param)
  self.info = param
  self.waitResponse = false
  self:updateView({})
end

function WinBastionNpcDoorHackIcon:updateView()
  local amount = Me:getCostItemCountByItemID(Define.Bastion.DoorHackItemID) or 0
  self.txtAmount:setText(amount)
end

function WinBastionNpcDoorHackIcon:onOpen(param)
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionNpcDoorHackIcon:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinBastionNpcDoorHackIcon:requestHack()
  if self.waitResponse then
    return
  end
  local hackObjID = Me:bhp_getHackObjID()
  if 0 < hackObjID then
    return
  end
  self.waitResponse = true
  Blockman.instance:control().enable = false
  local param = {
    type = "Start",
    objID = self.info.objID
  }
  Me:ndp_C2S_RequestHackNpcDoor(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:updateView()
    else
      Blockman.instance:control().enable = true
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

return WinBastionNpcDoorHackIcon

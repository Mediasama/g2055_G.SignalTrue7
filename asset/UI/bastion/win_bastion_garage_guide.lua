local WinBastionGarageGuide = M

function WinBastionGarageGuide:initUI()
  self.btnClose = self:child("ButtonClose")
end

function WinBastionGarageGuide:initEvent()
  function self.btnClose.onMouseClick()
    self:close()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinBastionGarageGuide:initView(param)
  local param = {
    key = Define.Bastion.Facility.Type.Garage
  }
  Me:C2S_RecordGuide(param)
end

function WinBastionGarageGuide:updateView()
end

function WinBastionGarageGuide:onOpen(param)
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionGarageGuide:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
end

return WinBastionGarageGuide

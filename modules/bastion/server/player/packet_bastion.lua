local BastionManager = require("server.bastion_manager")
local handles = T(Player, "PackageHandlers")

function handles:C2S_OperateBastionFacility(packet)
  if self:isPlayerInDieState() then
    return
  end
  local param = packet
  param.operatorId = self.platformUserId
  return BastionManager.Instance():operateBastionFacility(param)
end

function handles:C2S_RequestHackDoor(packet)
  local type = packet.type
  if type == "cancel" then
    self:bst_CancelHack()
  elseif type == "confirm" then
    self:bst_ConfirmHack()
  end
end

function handles:C2S_RecordGuide(packet)
  local param = packet
  local key = param.key or ""
  self:recordBastionGuideTimes(key)
end

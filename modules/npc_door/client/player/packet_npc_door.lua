local handles = T(Player, "PackageHandlers")

function handles:ndp_S2C_TriggerHackNpcDoorUI(packet)
  local operateType = packet.operateType or ""
  if operateType == "Enter" then
    self:ndp_ShowHackDoorUI(packet)
  elseif operateType == "Exit" then
    self:ndp_CloseHackDoorUI(packet)
  end
end

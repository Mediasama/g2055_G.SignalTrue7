local handles = T(Player, "PackageHandlers")

function handles:ndp_C2S_RequestHackNpcDoor(param)
  return self:ndp_RSP_HackNpcDoor(param)
end

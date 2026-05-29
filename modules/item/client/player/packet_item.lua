local handles = T(Player, "PackageHandlers")

function handles:changeSelectWeapon(packet)
  local index = packet.index + 1
  Lib.emitEvent(Event.EVENT_CHANGE_WEAPON_VIEW, index)
end

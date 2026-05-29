local handles = T(Player, "PackageHandlers")

function handles:RequestRevive(packet)
  self:revive()
end

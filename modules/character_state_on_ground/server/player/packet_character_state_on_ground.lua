local handles = T(Player, "PackageHandlers")

function handles:onCarryPlayer(packet)
  self:carryPlayer(packet.userId)
end

function handles:onThrowPlayer(packet)
  return self:throwPlayer(packet.userId)
end

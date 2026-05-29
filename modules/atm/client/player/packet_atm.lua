local handles = T(Player, "PackageHandlers")

function handles:playATMHurtActionS2C(packet)
  local atm = World.CurWorld:getEntity(packet.atmOjbId)
  if atm and atm:cfg().action then
    atm:updateUpperAction(atm:cfg().action.hurt, -1, true)
  end
end

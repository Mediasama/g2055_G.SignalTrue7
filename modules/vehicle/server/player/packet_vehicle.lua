local handles = T(Player, "PackageHandlers")

function handles:jumpVehicle(packet)
  self:jumpVehicle(packet.params)
end

function handles:createVehicle(packet)
  self:createVehicle(packet.params)
end

function handles:rideOnVehicle(packet)
  return self:rideOnVehicle(packet.params)
end

function handles:createAndRideVehicle(packet)
  local entity = self:createVehicle(packet.params)
  self:rideOnVehicleEntity(entity)
end

function handles:changeUnlockCarItemNum(packet)
  if packet and packet.params then
    return self:changeUnlockCarItemNum(packet.params.num)
  end
  return false
end

function handles:tryStartUnlockVehicle(packet)
  return self:tryStartUnlockVehicle(packet.params)
end

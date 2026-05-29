local table_insert = table.insert
local CarConfig = T(Config, "VehicleBaseConfig")
local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.inUseCar = {
  false,
  false,
  true,
  true,
  nil,
  false
}
ValueDef.vehicleCfgId = {
  false,
  false,
  true,
  true,
  -1,
  false
}
ValueDef.isVehicleLock = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.vehicleOwner = {
  false,
  false,
  true,
  true,
  -1,
  false
}
ValueDef.hasPassenger = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.isVehicleUnlocking = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.isUnlocking = {
  false,
  false,
  true,
  true,
  0,
  false
}
local Entity = _ENV.Entity

function Entity:getAllVehicle()
  local allCfg = CarConfig:getAllCfgs()
  local data = {}
  for _, v in pairs(allCfg) do
    table_insert(data, v)
  end
  table.sort(data, function(a, b)
    return a.order < b.order
  end)
  return data
end

function Entity:getInUseCar()
  return self:getValue("inUseCar")
end

function Entity:setInUseCar(carInfo)
  return self:setValue("inUseCar", carInfo)
end

function Entity:checkVehicleIsPrimary(id)
  return true
end

function Entity:getIsVehicleLock()
  return self:getValue("isVehicleLock") == Define.VEHICLE_LOCK_STATE.Lock
end

function Entity:setIsVehicleLock(stateFlag)
  return self:setValue("isVehicleLock", stateFlag)
end

function Entity:getVehicleOwner()
  return self:getValue("vehicleOwner")
end

function Entity:setVehicleOwner(ownerPlatformUserId)
  return self:setValue("vehicleOwner", ownerPlatformUserId)
end

function Entity:tryLockVehicle()
  local cfg = CarConfig:getCfgById(self:getVehicleCfgId())
  if cfg and cfg.vehicle_is_lock then
    self:setIsVehicleLock(Define.VEHICLE_LOCK_STATE.Lock)
  end
end

function Entity:getVehicleCfgId()
  return self:getValue("vehicleCfgId")
end

function Entity:setVehicleCfgId(id)
  return self:setValue("vehicleCfgId", id)
end

function Entity:getHasPassenger()
  return self:getValue("hasPassenger")
end

function Entity:setHasPassenger(flag)
  return self:setValue("hasPassenger", flag)
end

function Entity:getIsVehicleUnlocking()
  return self:getValue("isVehicleUnlocking")
end

function Entity:setIsVehicleUnlocking(state)
  return self:setValue("isVehicleUnlocking", state)
end

function Entity:canBeRideOn(player)
  if not self:isValid() then
    return false
  end
  if not player or not player:isValid() then
    return false
  end
  local passengers = self:data("passengers")
  if next(passengers) ~= nil then
    return false
  end
  local cfg = VehicleBaseConfig:getCfgById(self:getVehicleCfgId())
  local ownerId = self:getVehicleOwner()
  return cfg.vehicle_is_lock == 0 or ownerId == player.platformUserId
end

function Entity:canBeUnlock(player)
  if not self:isValid() then
    return false
  end
  if not player or not player:isValid() then
    return false
  end
  local passengers = self:data("passengers")
  if next(passengers) ~= nil then
    return false
  end
  local cfg = VehicleBaseConfig:getCfgById(self:getVehicleCfgId())
  local ownerId = self:getVehicleOwner()
  local itemNum = player:getUnlockCarItemNum()
  return cfg.vehicle_is_lock == 1 and ownerId ~= player.platformUserId and itemNum and 0 < itemNum
end

function Entity:canBeHitBack()
  if not self.isPlayer then
    return false
  end
  if self:getIsUnlocking() == 1 then
    return false
  end
  local hackObj = World.CurWorld:getEntity(self:bhp_getHackObjID())
  if hackObj then
    return false
  end
  return true
end

function Entity:getIsUnlocking()
  return self:getValue("isUnlocking")
end

function Entity:setIsUnlocking(state)
  return self:setValue("isUnlocking", state)
end

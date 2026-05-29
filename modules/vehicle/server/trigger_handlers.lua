local VehicleManager = T(Lib, "VehicleManager")
local Handlers = T(Trigger, "Handlers")

function Handlers.ENTITY_RIDE_ON(context)
  local car = context.obj1
  local player = context.obj2
  if not (car and car:isValid() and player) or not player:isValid() then
    return
  end
  local updateActorFun = car:cfg().updateActorFun
  if updateActorFun and car[updateActorFun] then
    car[updateActorFun](car)
  end
  player.startRideTime = os.time()
  player.startRidePosition = player:getPosition()
  if car:cfg().isTrolley then
    VehicleManager:vehicleRideOnReport(player, car)
    player:sendPacket({
      pid = "playerRideOn",
      viewFovAngle = car:cfg().vehicleViewFovAngle,
      vehicleId = car.objID
    })
    if car:getVehicleOwner() ~= player.platformUserId then
      local oldOwner = Game.GetPlayerByUserId(car:getVehicleOwner())
      if oldOwner and oldOwner:isValid() then
        oldOwner:removeVehicleInBag(car)
        VehicleManager:vehicleLostReport(Define.ReportCostAccessType.RideOn, oldOwner, car:getVehicleCfgId())
      end
      player:putVehicleInBag(car)
      VehicleManager:vehicleGetReport(Define.ReportGetAccessType.RideOn, player, car:getVehicleCfgId())
    end
    car:cancelDestroyTimer()
    car:addVehicleBuffByState("IDLE")
    World.Timer(1, function()
      car:setHasPassenger(1)
    end)
    VehicleManager:carCancelUnlocking(car.objID)
  end
end

function Handlers.ENTITY_RIDE_OFF(context)
  local car = context.obj1
  local player = context.obj2
  if not (car and car:isValid() and player) or not player:isValid() then
    return
  end
  local updateActorFun = car:cfg().updateActorFun
  if updateActorFun and car[updateActorFun] then
    car[updateActorFun](car)
  end
  if car:cfg().isTrolley then
    VehicleManager:vehicleRideOffReport(player, car)
  end
  if car:cfg().isTrolley then
    player:sendPacket({
      pid = "playerRideOff",
      vehicleId = car.objID
    })
    car:tryLockVehicle()
    car:startDestroyTimer()
    car:clearVehicleBuff()
    car:setHasPassenger(0)
  end
end

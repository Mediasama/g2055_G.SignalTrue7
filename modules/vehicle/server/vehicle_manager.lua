local CarConfig = T(Config, "VehicleBaseConfig")
local VehicleManager = T(Lib, "VehicleManager")

function VehicleManager:init()
  self.unlockInfDict = {}
  self.vehicleManagerTimer = World.Timer(1, function()
    self:update()
    return true
  end)
end

function VehicleManager:update()
  self:updateUnlockCarInf()
end

function VehicleManager:updateUnlockCarInf()
  for carId, lockInfList in pairs(self.unlockInfDict) do
    local carUnlockFinish = false
    for playerId, inf in pairs(lockInfList) do
      if os.time() >= inf.endTime then
        local car = World.CurWorld:getEntity(carId)
        if car and car:isValid() then
          car:setIsVehicleUnlocking(0)
        end
        local player = Game.GetPlayerByUserId(playerId)
        if player and player:isValid() then
          player:unlockVehiclePlayerEnd(carId, true)
        end
        carUnlockFinish = true
        lockInfList[playerId] = nil
        break
      end
    end
    if carUnlockFinish then
      for playerId, inf in pairs(lockInfList) do
        local player = Game.GetPlayerByUserId(playerId)
        if player and player:isValid() then
          player:unlockVehiclePlayerEnd(carId, false)
        end
      end
      self.unlockInfDict[carId] = nil
    end
  end
end

function VehicleManager:tryUnlockCar(playerId, carId)
  if not playerId or not carId then
    return false
  end
  return true
end

function VehicleManager:addUnlockInf(playerId, carId)
  if not playerId or not carId then
    return
  end
  local car = World.CurWorld:getEntity(carId)
  if not car or not car:isValid() then
    return
  end
  local player = Game.GetPlayerByUserId(playerId)
  if not player or not player:isValid() then
    return
  end
  if not self.unlockInfDict[carId] then
    self.unlockInfDict[carId] = {}
  end
  local infList = self.unlockInfDict[carId]
  local cfg = CarConfig:getCfgById(car:getVehicleCfgId())
  local unlockTime = cfg.vehicle_unlock_time or 8
  local inf = {}
  inf.playerId = playerId
  inf.carId = carId
  inf.startTime = os.time()
  inf.endTime = inf.startTime + unlockTime
  infList[playerId] = inf
  player:unlockVehiclePlayerBegin(carId)
  car:setIsVehicleUnlocking(1)
end

function VehicleManager:playerCancelUnlocking(playerId)
  print("-------------------------- VehicleManager:playerCancelUnlocking,playerId: ", playerId)
  if not playerId then
    return
  end
  for carId, lockInfList in pairs(self.unlockInfDict) do
    if lockInfList[playerId] then
      local player = Game.GetPlayerByUserId(playerId)
      if player and player:isValid() then
        player:unlockVehiclePlayerEnd(carId, false)
      end
      lockInfList[playerId] = nil
      if next(lockInfList) == nil then
        self.unlockInfDict[carId] = nil
        local car = World.CurWorld:getEntity(carId)
        if car and car:isValid() then
          car:setIsVehicleUnlocking(0)
        end
      end
      break
    end
  end
end

function VehicleManager:carCancelUnlocking(carId)
  print("-------------------------- VehicleManager:carCancelUnlocking,carId: ", carId)
  if not carId then
    return
  end
  local infList = self.unlockInfDict[carId]
  if infList and next(infList) ~= nil then
    local car = World.CurWorld:getEntity(carId)
    if car and car:isValid() then
      car:setIsVehicleUnlocking(0)
    end
    for playerId, inf in pairs(infList) do
      local player = Game.GetPlayerByUserId(playerId)
      if player and player:isValid() then
        player:unlockVehiclePlayerEnd(carId, false)
      end
    end
    self.unlockInfDict[carId] = nil
  end
end

Lib.subscribeEvent(Event.EVENT_PLAYER_DEATH, function(objID, obj)
  if obj and obj:isValid() then
    VehicleManager:playerCancelUnlocking(obj.platformUserId)
  end
end)
Lib.subscribeEvent(Event.EVENT_PLAYER_ENTER_DYING, function(objID, obj)
  if obj and obj:isValid() then
    VehicleManager:playerCancelUnlocking(obj.platformUserId)
  end
end)

function VehicleManager:vehicleRideOnReport(player, vehicle)
  if not (player and vehicle and player:isValid()) or not vehicle:isValid() then
    return
  end
  local reportData = {}
  reportData.car_owner_id = vehicle:getVehicleOwner()
  reportData.team_id = player:getGangId()
  reportData.car_hp = vehicle:getCurHp()
  player:evt_reportEvent(Define.EventTracking.Type.CarDrive, reportData, true)
end

function VehicleManager:vehicleRideOffReport(player, vehicle)
  local reportData = {}
  local distance = math.floor(Lib.getPosDistance(player.startRidePosition, player:getPosition()))
  reportData.car_owner_id = vehicle:getVehicleOwner()
  reportData.drive_length = distance
  reportData.drive_time = os.time() - (player.startRideTime or 0)
  reportData.car_hp = vehicle:getCurHp()
  player:evt_reportEvent(Define.EventTracking.Type.CarArrive, reportData, true)
end

function VehicleManager:vehicleUnlockReport(status, player, vehicle)
  local owner = Game.GetPlayerByUserId(vehicle:getVehicleOwner())
  local reportData = {}
  reportData.status = status
  reportData.target_car_id = vehicle:getVehicleCfgId()
  reportData.target_owner_id = vehicle:getVehicleOwner()
  reportData.target_owner_team_id = owner and owner:isValid() and owner:getGangId() or nil
  reportData.target_car_hp = vehicle:getCurHp()
  player:evt_reportEvent(Define.EventTracking.Type.CarUnlock, reportData, true)
end

function VehicleManager:vehicleBumpReport(vehicle, target)
  if not (vehicle and target and target:isValid()) or not target.cfg then
    return
  end
  local _, passengerId = next(vehicle:data("passengers"))
  local player = World.CurWorld:getEntity(passengerId)
  if not player or not player:isValid() then
    return
  end
  local targetVehicle, targetPlayer
  if target.isPlayer then
    targetPlayer = target
  elseif target:cfg().isTrolley then
    targetVehicle = target
  end
  if not targetVehicle and not targetPlayer then
    return
  end
  local reportData = {}
  local bumpType = targetPlayer and Define.EventTracking.CarBump.BumpType.Player or targetVehicle:getCurSpeed() > 0 and Define.EventTracking.CarBump.BumpType.MoveCar or Define.EventTracking.CarBump.BumpType.StaticCar
  local targetOwner = targetVehicle and Game.GetPlayerByUserId(targetVehicle:getVehicleOwner()) or nil
  reportData.bump_type = bumpType
  reportData.car_hp = vehicle:getCurHp()
  reportData.car_speed = math.floor(vehicle:getCurSpeed() * 1000)
  reportData.bump_time = os.time() - (player.startRideTime or 0)
  reportData.target_car_id = targetVehicle and targetVehicle:getVehicleCfgId() or -1
  reportData.target_owner_id = targetPlayer and targetPlayer.platformUserId or targetVehicle:getVehicleOwner()
  reportData.target_owner_team_id = targetPlayer and targetPlayer:getGangId() or targetOwner and targetOwner:getGangId() or nil
  reportData.target_car_hp = targetVehicle and targetVehicle:getCurHp() or -1
  player:evt_reportEvent(Define.EventTracking.Type.CarBump, reportData, true)
end

function VehicleManager:vehicleGetReport(accessType, player, vehicleId)
  if not (accessType and player and player:isValid()) or not vehicleId then
    return
  end
  local d = {}
  d.access_type = accessType
  d.item_type = Define.ReportItemType.Vehicle
  d.item_id = vehicleId
  d.gain_amount = 1
  d.current_num = player:getVehicleNumInBag(vehicleId)
  player:reportItemGet(d)
end

function VehicleManager:vehicleLostReport(accessType, player, vehicleId)
  if not (accessType and player and player:isValid()) or not vehicleId then
    return
  end
  local d = {}
  d.access_type_drop = accessType
  d.item_type = Define.ReportItemType.Vehicle
  d.item_id = vehicleId
  d.drop_amount = 1
  d.current_num = player:getVehicleNumInBag(vehicleId)
  player:reportItemCost(d)
end

VehicleManager:init()
return VehicleManager

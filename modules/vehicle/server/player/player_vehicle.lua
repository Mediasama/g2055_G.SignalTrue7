local CarConfig = T(Config, "VehicleBaseConfig")
local VehicleManager = T(Lib, "VehicleManager")
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local BastionConfig = T(Config, "BastionConfig")
local Player = _ENV.Player

function Player:jumpVehicle(params)
  if params and params.id then
    self:removeCurVehicle(self:getInUseCar())
  end
end

function Player:removeCurVehicle(useCarInfo)
  if not useCarInfo then
    return
  end
  local target = World.CurWorld:getEntity(useCarInfo.objId)
  if target then
    target:clearRide()
    self:setInUseCar(nil)
    return true
  end
  return false
end

function Player:createVehicle(params)
  local carConf = CarConfig:getCfgById(params.id)
  if carConf then
    local throwPos = {
      5,
      1,
      0,
      0
    }
    local cfgName = carConf.throwCfgName
    if cfgName then
      local dis = throwPos[1] or 0
      local offset = Lib.v3(throwPos[2] or 0, throwPos[3] or 0, throwPos[4] or 0)
      local pos
      if params.pos then
        pos = params.pos
      else
        pos = self:getFrontPos(dis, true, false) + offset
      end
      local rotation
      if params.rotation and params.rotation.y and type(params.rotation.y) == "number" then
        rotation = params.rotation.y
      else
        rotation = self:getRotationYaw()
      end
      Lib.logInfo(">>>>>>>>>>>>>>>>>> createVehicle,rotation:", self:getRotationYaw(), params.rotation)
      local data = {
        cfgName = cfgName,
        map = self.map,
        pos = pos,
        ry = rotation
      }
      local entity = EntityServer.Create(data)
      entity:setVehicleCfgId(params.id)
      self:putVehicleInBag(entity)
      entity:startDestroyTimer()
      local maxHp = carConf.vehicle_hp or 1
      entity:setVehicleMaxHp(maxHp)
      entity:doSetProp("newTouchCollisionMask", Define.VEHICLE_TOUCH_GROUP_SERVER)
      return entity
    end
  end
  return nil
end

function Player:rideOnVehicle(params)
  if self:isPlayerInDieState() then
    return false
  end
  if params and params.vehicleId then
    local vehicle = World.CurWorld:getEntity(params.vehicleId)
    if vehicle and vehicle:isValid() and vehicle:canBeRideOn(self) then
      self:rideOnVehicleEntity(vehicle)
      return true
    end
  end
  return false
end

function Player:rideOnVehicleEntity(vehicleEntity)
  if vehicleEntity and vehicleEntity:isValid() then
    self:setInUseCar({
      id = vehicleEntity:getVehicleCfgId(),
      objId = vehicleEntity.objID
    })
    local passengers = vehicleEntity:data("passengers")
    if next(passengers) == nil then
      self:rideOn(vehicleEntity, nil, 1)
    end
  end
end

function Player:canStartUnlockVehicle(vehicleId)
  if not self:canUnlockVehicle(vehicleId) then
    return false
  end
  local itemNum = self:getUnlockCarItemNum()
  if not itemNum or itemNum < 1 then
    return false
  end
  return true
end

function Player:canUnlockVehicle(vehicleId)
  if not self:isValid() then
    return false
  end
  if self:isPlayerInDieState() then
    return false
  end
  local vehicle = World.CurWorld:getEntity(vehicleId)
  if not vehicle or not vehicle:isValid() then
    return false
  end
  local passengers = vehicle:data("passengers")
  if next(passengers) ~= nil then
    return false
  end
  if vehicle:getVehicleOwner() == self.platformUserId then
    return false
  end
  if not vehicle:getIsVehicleLock() then
    return false
  end
  return true
end

function Player:tryStartUnlockVehicle(params)
  if not params or not params.vehicleId then
    return false
  end
  if not self:canStartUnlockVehicle(params.vehicleId) then
    return false
  end
  self:changeUnlockCarItemNum(-1)
  VehicleManager:addUnlockInf(self.platformUserId, params.vehicleId)
  local car = World.CurWorld:getEntity(params.vehicleId)
  if car and car:isValid() then
    local owner = Game.GetPlayerByUserId(car:getVehicleOwner())
    if owner and owner:isValid() then
      owner:sendPacket({
        pid = "showBoardTips",
        playerName = self:getName(),
        tipsKey = "vehicle.icon.beUnlock"
      })
    end
  end
  return true
end

function Player:buyCarFromShop(params, shelfID)
  if not params then
    return
  end
  local carId = params
  local shopId = shelfID
  local cvs = GoodsShelfConfig:getCfgById(shopId)
  if cvs then
    local car = self:createVehicle({
      id = carId,
      pos = cvs.carposition.position
    })
    self:rideOnVehicleEntity(car)
  end
end

function Player:stealCarFromGarage(params, ownerId)
  local carId = params
  local player = Game.GetPlayerByUserId(ownerId)
  if player and player:isValid() then
    local bastion = player:getBastion()
    if bastion then
      local bastionId = bastion:getUid(bastion)
      local cvs = BastionConfig:getCfgById(bastionId)
      if carId and cvs then
        local car = self:createVehicle({
          id = carId,
          pos = cvs.carposition.position
        })
        self:rideOnVehicleEntity(car)
      end
    end
  end
end

function Player:fetchCarFromGarage(params)
  local carId = params
  local player = self
  local bastion = player:getBastion()
  if bastion then
    local bastionId = bastion:getUid(bastion)
    local cvs = BastionConfig:getCfgById(bastionId)
    if carId and cvs then
      local car = self:createVehicle({
        id = carId,
        pos = cvs.carposition.position,
        rotation = cvs.carposition.rotation
      })
      self:rideOnVehicleEntity(car)
    end
  end
end

function Player:depositCarToGarage(params)
  local carId = params
  if carId then
    local useCarInfo = self:getInUseCar()
    if useCarInfo then
      local car = World.CurWorld:getEntity(useCarInfo.objId)
      if car and car:isValid() then
        self:removeVehicleInBag(car)
        self:removeCurVehicle(useCarInfo)
        car:destroy()
      end
    end
  end
end

function Player:fetchOldCarFromGarage(params)
  local carId = params
  local player = self
  local bastion = player:getBastion()
  if bastion then
    local bastionId = bastion:getUid(bastion)
    local cvs = BastionConfig:getCfgById(bastionId)
    if carId and cvs then
      self:createVehicle({
        id = carId,
        pos = cvs.carposition.position
      })
    end
  end
end

function Player:isDriving()
  return self:getInUseCar() ~= nil
end

function Player:getUnlockCarItemNum()
  return self:getCostItemCountByItemID(Define.VehicleHackItemID)
end

function Player:changeUnlockCarItemNum(num)
  local curNum = self:getCostItemCountByItemID(Define.VehicleHackItemID)
  if num < 0 and curNum < math.abs(num) then
    return false
  end
  self:changeCostItemCount(Define.VehicleHackItemID, num)
  local d = {}
  d.access_type_drop = Define.ReportCostAccessType.Self
  d.item_type = Define.ReportItemType.Item
  d.item_id = Define.VehicleHackItemID
  d.drop_amount = 1
  d.current_num = self:getCostItemCountByItemID(Define.VehicleHackItemID)
  self:reportItemCost(d)
  return true
end

function Player:unlockVehiclePlayerBegin(carId)
  print("+++++++++++++++++++++++ Player:unlockVehiclePlayerBegin ", carId)
  local car = World.CurWorld:getEntity(carId)
  if car and car:isValid() then
    self:sendPacket({
      pid = "unlockVehiclePlayerBeginClient",
      params = {carId = carId}
    })
    VehicleManager:vehicleUnlockReport(Define.EventTracking.CarUnlock.Status.Start, self, car)
    self:addBuff("myplugin/player_posture_pick_lock")
    self:setIsUnlocking(1)
  end
end

function Player:unlockVehiclePlayerEnd(carId, isFinish)
  print("+++++++++++++++++++++++ Player:unlockVehiclePlayerEnd ", self.platformUserId, carId, isFinish)
  self:setIsUnlocking(0)
  local isSuccess = false
  local car = World.CurWorld:getEntity(carId)
  if self:canUnlockVehicle(carId) and car and car:isValid() and isFinish then
    local cfg = CarConfig:getCfgById(car:getVehicleCfgId())
    if cfg then
      local rate = cfg.vehicle_unlock_pro
      if rate and 0 < rate then
        local rd = math.random() * 1000
        isSuccess = rate >= rd
        print("Player:unlockVehiclePlayerEnd,random=", rd, rate, self.platformUserId, isSuccess)
      end
    end
  end
  local reportStatus = isSuccess and Define.EventTracking.CarUnlock.Status.Success or isFinish and Define.EventTracking.CarUnlock.Status.Fail or Define.EventTracking.CarUnlock.Status.Break
  VehicleManager:vehicleUnlockReport(reportStatus, self, car)
  if isSuccess then
    local owner = Game.GetPlayerByUserId(car:getVehicleOwner())
    if owner and owner:isValid() then
      owner:removeVehicleInBag(car)
      VehicleManager:vehicleLostReport(Define.ReportCostAccessType.RobBeDecoder, owner, car:getVehicleCfgId())
    end
    self:putVehicleInBag(car)
    VehicleManager:vehicleGetReport(Define.ReportGetAccessType.RobDecoder, self, car:getVehicleCfgId())
  end
  print("+++++++++++++++++++++++ Player:unlockVehiclePlayerEnd result: ", carId, isFinish, isSuccess)
  self:sendPacket({
    pid = "unlockVehiclePlayerEndClient",
    params = {carId = carId, isSuccess = isSuccess}
  })
  self:removeTypeBuff("fullName", "myplugin/player_posture_pick_lock")
  return isSuccess
end

function Player:trySendHitVehicleMsg(vehicleOwner, vehicleEntityId)
  if not vehicleOwner or not vehicleOwner:isValid() then
    return false
  end
  if self:checkHitVehicleReportCD(vehicleEntityId) then
    vehicleOwner:sendPacket({
      pid = "showBoardTips",
      playerName = self:getName(),
      tipsKey = "vehicle.icon.beAttack"
    })
    return true
  else
    return false
  end
end

function Player:recordHitVehicleTime(vehicleEntityId)
  if self.hitVehicleTimeRecordMap == nil then
    self.hitVehicleTimeRecordMap = {}
  end
  self.hitVehicleTimeRecordMap[vehicleEntityId] = os.time()
end

function Player:checkHitVehicleReportCD(vehicleEntityId)
  local reportCD = World.cfg.hitVehicleReportCD
  if self.hitVehicleTimeRecordMap == nil then
    self.hitVehicleTimeRecordMap = {}
  end
  if self.hitVehicleTimeRecordMap[vehicleEntityId] == nil then
    return true
  else
    return reportCD <= os.time() - self.hitVehicleTimeRecordMap[vehicleEntityId]
  end
end

function Player:putVehicleInBag(vehicle)
  if not vehicle or not vehicle:isValid() then
    return
  end
  vehicle:setVehicleOwner(self.platformUserId)
  self:changeVehicleCount(vehicle:getVehicleCfgId(), 1)
end

function Player:removeVehicleInBag(vehicle)
  if not vehicle or not vehicle:isValid() then
    return
  end
  self:changeVehicleCount(vehicle:getVehicleCfgId(), -1)
end

function Player:getVehicleNumInBag(vehicleId)
  return self:getVehicleCountByItemID(vehicleId)
end

function Player:getPassCardRewardCar(carId)
  if not carId then
    return
  end
  if self:isDriving() then
    self:removeCurVehicle(self:getInUseCar())
  end
  self:clearMyCarrier()
  local carPos = World.cfg.passCardCarPos or {
    x = 65.33,
    y = 30.2,
    z = -4.47
  }
  local car = self:createVehicle({id = carId, pos = carPos})
  self:rideOnVehicleEntity(car)
  local reportData = {}
  reportData.access_type = Define.EventTracking.Item.Gain.PassCard
  reportData.item_type = Define.EventTracking.Item.Type.Car
  reportData.item_id = carId
  reportData.gain_amount = 1
  reportData.current_num = 1
  self:evt_reportEvent(Define.EventTracking.Type.GainItem, reportData)
end

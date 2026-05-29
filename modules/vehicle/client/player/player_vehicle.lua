local Player = _ENV.Player
local SoundConfig = T(Config, "SoundConfig")

function Player:playerNearVehicle(inf)
  if Lib.isDebugCloseUI() then
    return
  end
  if Me:isDriving() then
    return
  end
  local vehicle = World.CurWorld:getEntity(inf.vehicleId)
  if vehicle and vehicle:isValid() and vehicle:canShowInteractIcon() then
    local sceneWindow = UI:getSceneWindow("win_vehicle__icons" .. inf.vehicleId)
    if not sceneWindow then
      local args = {
        position = Vector3.new(0, 3, 0),
        width = 4.37,
        height = 1.37,
        objID = inf.vehicleId,
        flags = 4,
        rotation = {
          0,
          0,
          0
        },
        isCullBack = false
      }
      UI:openNewCustomSceneWindow("./UI/vehicle/win_vehicle__icons", "win_vehicle__icons" .. inf.vehicleId, args, {
        vehicleId = inf.vehicleId
      })
      Me:evt_reportWinOpen("./UI/vehicle/win_vehicle__icons")
    end
  end
end

function Player:playerLeaveVehicle(inf)
  UI:closeSceneWindow("win_vehicle__icons" .. inf.vehicleId)
  Me:evt_reportWinClose("win_vehicle__icons" .. inf.vehicleId)
end

function Player:playCarClashSound(packet)
  local sound = SoundConfig:getSound("vehicle_clash")
  local useCarInfo = Me:getInUseCar()
  if useCarInfo then
    local car = World.CurWorld:getEntity(useCarInfo.objId)
    if car and car:isValid() then
      local speed = math.sqrt(car.motion.x * car.motion.x + car.motion.z * car.motion.z)
      local carSpeed = car:cfg().moveSpeed or 1
      if speed >= carSpeed / 3 then
        Me:playSound(SoundConfig:getSound("vehicle_clash"))
      end
    end
  end
end

function Player:isDriving()
  return self:getInUseCar() ~= nil
end

function Player:getUnlockCarItemNum()
  return self:getCostItemCountByItemID(Define.VehicleHackItemID)
end

function Player:getCurYaw()
  if self:isDriving() then
    local inf = self:getInUseCar()
    if inf then
      local car = World.CurWorld:getEntity(inf.objId)
      if car and car:isValid() then
        return car:getRotationYaw()
      end
    end
  end
  return self:getRotationYaw()
end

function Player:unlockVehiclePlayerBeginClient(packet)
  Lib.logInfo(">>>>>>>>>>>>>>>>>> unlockVehiclePlayerBeginClient(packet) ", self.platformUserId, packet.params.carId)
  Lib.emitEvent(Event.EVENT_ENTER_UNLOCK_CAR, packet.params.carId)
end

function Player:unlockVehiclePlayerEndClient(packet)
  Blockman.instance:control().enable = true
  local isSuccess = false
  if packet then
    isSuccess = packet.params.isSuccess
  end
  Lib.logInfo(">>>>>>>>>>>>>>>>>> unlockVehiclePlayerEndClient(packet) ", self.platformUserId, packet.params.carId, isSuccess)
  local tips = isSuccess and "vehicle.icon.unlock.success" or "vehicle.icon.unlock.fail"
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(tips))
  Lib.emitEvent(Event.EVENT_EXIT_UNLOCK_CAR, isSuccess, packet.params.carId)
  Me.weapon:initAction()
end

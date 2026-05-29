local handles = T(Player, "PackageHandlers")
local viewsDisBeforeRideOn = 3.5
local Player = _ENV.Player

function handles:playerRideOn(packet)
  viewsDisBeforeRideOn = Blockman.Instance():viewerRenderDistance()
  Lib.openWindow("./UI/vehicle/win_vehicle_ctrl")
  Lib.emitEvent(Event.EVENT_RIDE_ON_CAR, packet.vehicleId)
  Me:changeCameraView(nil, nil, nil, packet.viewFovAngle, 0)
end

function handles:playerRideOff(packet)
  Me:changeCameraView(nil, nil, nil, viewsDisBeforeRideOn, 0)
  Lib.closeWindow("./UI/vehicle/win_vehicle_ctrl")
  Lib.emitEvent(Event.EVENT_RIDE_OFF_CAR, packet.vehicleId)
end

function handles:playCarClashSound(packet)
  self:playCarClashSound(packet)
end

function handles:unlockVehiclePlayerBeginClient(packet)
  self:unlockVehiclePlayerBeginClient(packet)
end

function handles:unlockVehiclePlayerEndClient(packet)
  self:unlockVehiclePlayerEndClient(packet)
end

function handles:showBoardTips(packet)
  if not packet then
    return
  end
  local playerName = packet.playerName or ""
  local content = playerName .. Lang:toText(packet.tipsKey)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalBattleTips", content)
end

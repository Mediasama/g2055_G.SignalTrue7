local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
M.VehicleIconState = {
  CanDrive = 1,
  Lock = 2,
  CanUnLock = 3,
  UnLocking = 4
}
M.VehicleIconStateText = {
  "vehicle.icon.text.canDrive",
  "vehicle.icon.text.cannotUnlock",
  "vehicle.icon.text.canUnlock"
}
M.VehicleIconImageList = {
  "set:g2055_scenes.json image:icon_0_drive_01",
  "set:g2055_scenes.json image:icon_0_drive_02",
  "set:g2055_scenes.json image:icon_0_drive_03"
}
M.TIMER_FRAME_INTERVAL = 2

function M:init()
  self.vehicleId = nil
  self.state = nil
  self.barTimer = nil
  self.progress = 0
  self.barStep = 0.1
  self.timeRemain = 0
  self._allEvent = {}
  self.data = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.panelIcon = self.PanelIcon
  self.panelBar = self.PanelBar
  self.icon = self:child("ImageIcon")
  self.inf = self:child("TextInf")
  self.text = self:child("Text")
  self.imageBG = self:child("ImageBG")
  self.bar = self.PanelBar.ProgressBar
  self.PanelBar.TextProgress:setText(Lang:toText("vehicle.icon.unlocking"))
end

function M:initEvent()
  function self.imageBG.onWindowTouchDown()
    if self.vehicleId then
      local vehicle = World.CurWorld:getEntity(self.vehicleId)
      
      if vehicle and vehicle:isValid() then
        Me:playSoundByKey("g2055_commonButtonSound")
        if self.state == M.VehicleIconState.CanDrive then
          Me:pam_C2S_RequestStopMotion()
          local params = {
            vehicleId = self.vehicleId
          }
          Me:sendPacket({
            pid = "rideOnVehicle",
            params = params
          }, function(ret)
            print(">>>>>>>>>>>>>>>>>>>>>>> ride on: ret:", ret)
            self:resetUI()
          end)
        elseif self.state == M.VehicleIconState.CanUnLock then
          Me:pam_C2S_RequestStopMotion()
          Blockman.instance:control().enable = false
          Me:sendPacket({
            pid = "tryStartUnlockVehicle",
            params = {
              vehicleId = self.vehicleId
            }
          }, function(ret)
            print("--tryStartUnlockVehicle--,ret:", ret)
            if not ret then
              Lib.emitEvent(Event.EVENT_EXIT_UNLOCK_CAR, false, self.vehicleId)
            end
          end)
        elseif self.state == M.VehicleIconState.Lock then
          Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("vehicle.icon.noUnlockItem"))
        end
      end
    end
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTER_UNLOCK_CAR, function(carId)
    if carId == self.vehicleId then
      self:setState(M.VehicleIconState.UnLocking)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_EXIT_UNLOCK_CAR, function(isSuccess, carId)
    if carId == self.vehicleId then
      self:resetUI()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HAS_PASSENGER, function(value, carId)
    if carId == self.vehicleId then
      self:resetUI()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objId, obj)
    if objId == self.vehicleId then
      UI:closeSceneWindow("win_vehicle__icons" .. self.vehicleId)
    end
  end)
end

function M:onOpen(data)
  self.data = data
  self.vehicleId = self.data.vehicleId
  local vehicleEntity = World.CurWorld:getEntity(self.vehicleId)
  if vehicleEntity and vehicleEntity:isValid() then
    local cfg = VehicleBaseConfig:getCfgById(vehicleEntity:getVehicleCfgId())
    self.timeRemain = cfg.vehicle_unlock_time
  end
  self:resetUI()
end

function M:resetUI()
  if self.data and self.vehicleId then
    local vehicleEntity = World.CurWorld:getEntity(self.vehicleId)
    if not (vehicleEntity and vehicleEntity:isValid()) or not vehicleEntity:canShowInteractIcon() then
      UI:closeSceneWindow("win_vehicle__icons" .. self.vehicleId)
      return
    end
    if vehicleEntity:canBeRideOn(Me) then
      self:setState(M.VehicleIconState.CanDrive)
    elseif vehicleEntity:canBeUnlock(Me) then
      self:setState(M.VehicleIconState.CanUnLock)
    else
      self:setState(M.VehicleIconState.Lock)
    end
  end
end

function M:setState(state)
  self.state = state
  self.panelIcon:setVisible(state ~= M.VehicleIconState.UnLocking)
  self.panelBar:setVisible(state == M.VehicleIconState.UnLocking)
  local stateText = M.VehicleIconStateText[state]
  if stateText then
    self.text:setText(Lang:toText(stateText))
  end
  self:cancelTimer()
  if state == M.VehicleIconState.UnLocking then
    print(">>>>>>>>>>>>>>>> vehicle enter  unlocking")
    self.bar:setProgress(0)
    self.progress = 0
    self.barStep = 0 >= self.timeRemain and 1 or M.TIMER_FRAME_INTERVAL / 20 / self.timeRemain
    self.barTimer = World.Timer(M.TIMER_FRAME_INTERVAL, function()
      self.progress = self.progress + self.barStep
      self.bar:setProgress(self.progress)
      if self.progress >= 1 then
        return false
      end
      return true
    end)
  else
    local imageSet = M.VehicleIconImageList[state]
    if imageSet then
      self.icon:setImage(imageSet)
    end
    self.inf:setVisible(state == M.VehicleIconState.CanUnLock)
    if state == M.VehicleIconState.CanUnLock then
      self.inf:setText(Me:getUnlockCarItemNum())
    end
  end
end

function M:onClose()
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> vehicle icons onClose(),barTimer:", self.barTimer)
  self:cancelTimer()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if not Me:isDriving() then
    Lib.emitEvent(Event.EVENT_EXIT_UNLOCK_CAR, false, self.vehicleId)
  end
end

function M:cancelTimer()
  if self.barTimer then
    self.barTimer()
    self.barTimer = nil
  end
end

M:init()

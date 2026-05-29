local CameraManager = T(Lib, "CameraManager")
local Instance = Blockman.instance

function CameraManager:changeCameraView(yaw, pitch)
  local pos = Instance:getViewerPos()
  local distance = Instance:viewerRenderDistance()
  Instance:changeCameraView(pos, yaw, pitch, distance, 1)
end

function CameraManager:changeCameraYaw(offset, smooth)
  local pos = Instance:getViewerPos()
  local distance = Instance:viewerRenderDistance()
  local pitch = Instance:viewerRenderPitch()
  local yaw = Instance:viewerRenderYaw() + offset
  Instance:changeCameraView(pos, yaw, pitch, distance, smooth or 1)
  Me:setBodyYawEx(yaw)
end

function CameraManager:weaponView(cameraCfg)
  GlobalProperty.Instance():setFloatProperty("MaxYMotion", World.cfg.maxYMotion or -2.0)
  GlobalProperty.Instance():setBoolProperty("DisableThirdPersonCameraOffset", false)
  if Me then
    Me:setProp("calcYawBySpeedDir", 0)
    Me:sendPacket({
      pid = "ChangeViewMode",
      mode = 1
    })
  end
  Blockman.instance.gameSettings:setLockBodyRotation(true)
  if cameraCfg then
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraHorizontalOffset", cameraCfg.cameraXOffset)
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraVerticalOffset", cameraCfg.cameraYOffset)
    Blockman.instance:setViewFovAngle(cameraCfg.cameraFovAngle)
    if cameraCfg.cameraDistance then
      Me:changeCameraView(nil, cameraCfg.yaw, cameraCfg.pitch, cameraCfg.cameraDistance, 0)
    end
  else
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraHorizontalOffset", 0.7)
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraVerticalOffset", 0.6)
    Blockman.instance:setViewFovAngle(World.cfg.weaponViewFovAngle)
  end
  Camera.getActiveCamera():update()
  self.isFreeView = false
  local bm = Blockman:Instance()
  local yaw = bm:getViewerYaw()
  Me:setBodyYawEx(yaw)
end

function CameraManager:freeViewNoLock(cameraCfg)
  Blockman.instance.gameSettings:setLockBodyRotation(false)
  if cameraCfg then
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraHorizontalOffset", cameraCfg.cameraXOffset)
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraVerticalOffset", cameraCfg.cameraYOffset)
    Blockman.instance:setViewFovAngle(cameraCfg.cameraFovAngle)
    if cameraCfg.cameraDistance then
      print("cameraCfg.yaw, cameraCfg.pitch", cameraCfg.yaw, cameraCfg.pitch)
      local yaw = cameraCfg.yaw
      if not self.setOnce then
        self.setOnce = true
        yaw = Me:getBodyYaw()
      end
      Me:changeCameraView(nil, yaw, cameraCfg.pitch, cameraCfg.cameraDistance, 0)
    end
    self.lastCameraCfg = cameraCfg
  else
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraHorizontalOffset", 0)
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraVerticalOffset", 0)
    Blockman.instance:setViewFovAngle(World.cfg.initViewFovAngle)
  end
  if Me then
    Me:setProp("calcYawBySpeedDir", 1)
    Me:sendPacket({
      pid = "ChangeViewMode",
      mode = 0
    })
  end
  Camera.getActiveCamera():update()
  self.isFreeView = true
  local yaw = Me:getBodyYaw()
  Me:resetBodyYaw(yaw)
end

function CameraManager:freeView(cameraCfg)
  local lockCamera = cameraCfg and cameraCfg.lockCamera
  if lockCamera then
    self:weaponView(cameraCfg)
  else
    self:freeViewNoLock(cameraCfg)
  end
end

function CameraManager:freeViewLock(cameraCfg)
  GlobalProperty.Instance():setBoolProperty("DisableThirdPersonCameraOffset", false)
  if Me then
    Me:setProp("calcYawBySpeedDir", 0)
    Me:sendPacket({
      pid = "ChangeViewMode",
      mode = 1
    })
  end
  Blockman.instance.gameSettings:setLockBodyRotation(true)
  if cameraCfg then
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraHorizontalOffset", cameraCfg.cameraXOffset)
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraVerticalOffset", cameraCfg.cameraYOffset)
    Blockman.instance:setViewFovAngle(cameraCfg.cameraFovAngle)
    if cameraCfg.cameraDistance then
      Me:changeCameraView(nil, cameraCfg.yaw, cameraCfg.pitch, cameraCfg.cameraDistance, 0)
    end
  else
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraHorizontalOffset", 0)
    GlobalProperty.Instance():setFloatProperty("ThirdPersonCameraVerticalOffset", 0)
    Blockman.instance:setViewFovAngle(World.cfg.weaponViewFovAngle)
  end
  Camera.getActiveCamera():update()
  self.isFreeView = true
  local bm = Blockman:Instance()
  local yaw = bm:getViewerYaw()
  Me:setBodyYawEx(yaw)
end

function CameraManager:resetCamera()
  local Cinemachine = T(Lib, "LuaCinemachine")
  Cinemachine:enable(false)
  local cameraCfg = World.cfg.fightCameraCfg
  if cameraCfg then
    Blockman.instance:setPersonView(cameraCfg.viewMode or 3)
    Me:changeCameraView(nil, cameraCfg.cameraView.yaw, cameraCfg.cameraView.pitch, cameraCfg.cameraDistance, 0)
  end
end

function CameraManager:lockCameraView()
end

function CameraManager:freeViewEx()
end

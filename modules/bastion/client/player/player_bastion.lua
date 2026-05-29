local facilityTypeToIconUIDict = {}
facilityTypeToIconUIDict[Define.Bastion.Facility.Type.Vault] = "./UI/bastion/win_bastion_vault_icon"
facilityTypeToIconUIDict[Define.Bastion.Facility.Type.Closet] = "./UI/bastion/win_bastion_closet_icon"
facilityTypeToIconUIDict[Define.Bastion.Facility.Type.Armory] = "./UI/bastion/win_bastion_armory_icon"
facilityTypeToIconUIDict[Define.Bastion.Facility.Type.ToolKit] = "./UI/bastion/win_bastion_toolkit_icon"
facilityTypeToIconUIDict[Define.Bastion.Facility.Type.Garage] = "./UI/bastion/win_bastion_garage_icon"
facilityTypeToIconUIDict[Define.Bastion.Facility.Type.DoorSensor] = "./UI/bastion/win_bastion_door_sensor_icon"

local function getFacilityIconUI(facilityType)
  return facilityTypeToIconUIDict[facilityType]
end

local PlayerBastionClient = Player

function PlayerBastionClient:showFacilityIcon(objID, facilityType, ownerId, operatorId, triggerParam)
  if Lib.isDebugCloseUI() then
    return
  end
  if not ownerId then
    return
  end
  local windowKey = facilityType .. tostring(ownerId)
  local sceneWindow = UI:getSceneWindow(windowKey)
  if not sceneWindow then
    local object = World.CurWorld:getObject(objID)
    if not object or not object:isValid() then
      return false
    end
    local offset = triggerParam.offset or Vector3.new(0, 0, 0)
    local width = triggerParam.width or 3
    local height = triggerParam.height or 3
    local parentRotation = Vector3.new(-object:getRotationPitch(), -object:getRotationYaw(), -object:getRotationRoll())
    Lib.rotate(offset, parentRotation)
    local position = object:getPosition() + offset
    local sceneArgs = {
      position = position,
      rotation = {
        0,
        0,
        0
      },
      width = width,
      height = height,
      isCullBack = false,
      objID = -1,
      flags = 4
    }
    local openParam = {}
    openParam.type = facilityType
    openParam.ownerId = ownerId
    openParam.operatorId = operatorId
    openParam.objID = objID
    openParam.triggerParam = triggerParam
    local windowName = getFacilityIconUI(facilityType)
    local sceneWnd, wnd = UI:openNewCustomSceneWindow(windowName, windowKey, sceneArgs, openParam)
    Me:evt_reportWinOpen(windowKey)
    sceneWindow = sceneWnd
  end
end

function PlayerBastionClient:hideFacilityIcon(objID, facilityType, ownerId)
  if not ownerId then
    return
  end
  local windowKey = facilityType .. tostring(ownerId)
  UI:closeSceneWindow(windowKey)
  Me:evt_reportWinClose(windowKey)
end

function PlayerBastionClient:showParkDialog(objID, facilityType, ownerId, operatorId, triggerParam)
  local openParam = {}
  openParam.type = facilityType
  openParam.ownerId = ownerId
  openParam.operatorId = operatorId
  openParam.objID = objID
  openParam.triggerParam = triggerParam
  local window = UI:isOpenWindow("./UI/bastion/win_bastion_garage")
  if window then
    window:onOpen(openParam)
  else
    UI:openCustomWindow("./UI/bastion/win_bastion_garage", "", openParam)
  end
end

function PlayerBastionClient:hideParkDialog(objID, facilityType, ownerId)
  Lib.closeWindow("./UI/bastion/win_bastion_garage")
end

function PlayerBastionClient:C2S_OperateBastionFacility(param, resp)
  param.pid = "C2S_OperateBastionFacility"
  self:sendPacket(param, resp)
end

function PlayerBastionClient:C2S_RequestHackDoor(param, resp)
  param.pid = "C2S_RequestHackDoor"
  self:sendPacket(param, resp)
end

function PlayerBastionClient:C2S_RecordGuide(param, resp)
  param.pid = "C2S_RecordGuide"
  self:sendPacket(param, resp)
end

function PlayerBastionClient:createHomeMark(param)
  self:removeHomeMark()
  local effectName = param.effectName or "g2055_reborn_effect.effect"
  local position = Vector3.new(param.position.x, param.position.y, param.position.z) or Vector3.new(0, 0, 0)
  local rotation = Vector3.new(param.rotation.x, param.rotation.y, param.rotation.z) or Vector3.new(0, 0, 0)
  self.homeEffect = EffectNode.Load(effectName)
  self.homeEffect:setLocalPosition(position)
  self.homeEffect:setLocalQuaternion(Quaternion.fromEulerAngleVector(rotation))
  self.homeEffect:setMaxViewDistance(1000)
  self.homeEffect:setViewRange({
    x = 0.5,
    y = 100,
    z = 0.5
  })
  local parent = World.CurMap:getScene():getRoot()
  parent:addChild(self.homeEffect)
end

function PlayerBastionClient:removeHomeMark()
  if not self.homeEffect then
    return
  end
  local parent = World.CurMap:getScene():getRoot()
  parent:removeChild(self.homeEffect)
  self.homeEffect = nil
end

function PlayerBastionClient:createDoorMark(param)
  self:removeDoorMark()
  self.homeIconWindowKey = "bastion_home_icon"
  local sceneArgs = {
    position = param.position,
    rotation = param.rotation,
    width = 3,
    height = 3,
    isCullBack = false,
    flags = 4
  }
  World.Timer(60, function()
    if self.homeIconWindowKey then
      local sceneWnd, wnd = UI:openNewCustomSceneWindow("./UI/bastion/win_bastion_home_icon", self.homeIconWindowKey, sceneArgs, {})
    end
  end)
end

function PlayerBastionClient:removeDoorMark()
  if self.homeIconWindowKey then
    UI:closeSceneWindow(self.homeIconWindowKey)
    self.homeIconWindowKey = nil
  end
end

function PlayerBastionClient:createParkMark(param)
  local garageLevel = self:getBastionGarageLevel()
  if 0 < garageLevel then
    self:removeParkMark()
    local effectName = param.effectName or "g2055_parking_effect.effect"
    local position = Vector3.new(param.position.x, param.position.y, param.position.z) or Vector3.new(0, 0, 0)
    local rotation = Vector3.new(param.rotation.x, param.rotation.y, param.rotation.z) or Vector3.new(0, 0, 0)
    self.parkEffect = EffectNode.Load(effectName)
    self.parkEffect:setLocalPosition(position)
    self.parkEffect:setLocalQuaternion(Quaternion.fromEulerAngleVector(rotation))
    self.parkEffect:setViewRange({
      x = 6,
      y = 0.5,
      z = 6
    })
    local parent = World.CurMap:getScene():getRoot()
    parent:addChild(self.parkEffect)
  end
end

function PlayerBastionClient:removeParkMark()
  if not self.parkEffect then
    return
  end
  local parent = World.CurMap:getScene():getRoot()
  parent:removeChild(self.parkEffect)
  self.parkEffect = nil
end

function PlayerBastionClient:getDoorPlate(param)
  local id = param.id
  if not self.doorPlateDict then
    self.doorPlateDict = {}
  end
  local doorplate = self.doorPlateDict[id]
  if not doorplate then
    doorplate = self:createDoorPlate(param)
    self.doorPlateDict[id] = doorplate
  end
  return doorplate
end

function PlayerBastionClient:createDoorPlate(param)
  if Lib.isDebugCloseUI() then
    return
  end
  local id = param.id
  self:removeDoorPlate(id)
  local windowKey = "bastion_doorplate_" .. tostring(id)
  local sceneArgs = {
    position = param.position,
    rotation = param.rotation,
    width = 3,
    height = 3,
    isCullBack = false,
    objID = -1,
    flags = 0
  }
  local sceneWnd, wnd = UI:openNewCustomSceneWindow("./UI/bastion/win_bastion_doorplate", windowKey, sceneArgs, {})
  return {sceneWnd = sceneWnd, wnd = wnd}
end

function PlayerBastionClient:removeDoorPlate(id)
  if not self.doorPlateDict then
    return
  end
  self.doorPlateDict[id] = nil
  local windowKey = "bastion_doorplate_" .. tostring(id)
  UI:closeSceneWindow(windowKey)
end

function PlayerBastionClient:updateDoorPlate(param)
  local id = param.id
  if not id then
    return
  end
  local doorplate = self:getDoorPlate(param)
  if not doorplate then
    return
  end
  doorplate.wnd:onOpen(param)
end

local BastionHome = require("server.bastion_home")
local BastionOperatorVault = require("server.bastion_operator.bastion_operator_vault")
local BastionOperatorCloset = require("server.bastion_operator.bastion_operator_closet")
local BastionOperatorToolkit = require("server.bastion_operator.bastion_operator_toolkit")
local BastionOperatorDoorSensor = require("server.bastion_operator.bastion_operator_door_sensor")
local BastionOperatorGarage = require("server.bastion_operator.bastion_operator_garage")
local BastionOperatorPark = require("server.bastion_operator.bastion_operator_park")
local BastionOperatorArmory = require("server.bastion_operator.bastion_operator_armory")
local BastionConfig = T(Config, "BastionConfig")
local BastionManager = Lib.class("BastionManager")
local _instance

function BastionManager.Instance()
  if _instance == nil then
    _instance = BastionManager.new()
    _instance:init()
  end
  return _instance
end

function BastionManager:ctor()
  self.bastionDict = {}
  self.operatorDict = {}
  self.loaded = false
  self.clearDeadBastionCounter = 0
  self.lastClearStamp = 0
  self.noEmptyBastionKickCounter = 0
end

function BastionManager:init()
  self.operatorDict[Define.Bastion.Facility.Type.Vault] = BastionOperatorVault.new()
  self.operatorDict[Define.Bastion.Facility.Type.Closet] = BastionOperatorCloset.new()
  self.operatorDict[Define.Bastion.Facility.Type.ToolKit] = BastionOperatorToolkit.new()
  self.operatorDict[Define.Bastion.Facility.Type.DoorSensor] = BastionOperatorDoorSensor.new()
  self.operatorDict[Define.Bastion.Facility.Type.Garage] = BastionOperatorGarage.new()
  self.operatorDict[Define.Bastion.Facility.Type.Park] = BastionOperatorPark.new()
  self.operatorDict[Define.Bastion.Facility.Type.Armory] = BastionOperatorArmory.new()
  self:startUpdateTimer()
end

function BastionManager:destroy()
  self:stopUpdateTimer()
end

function BastionManager:startUpdateTimer()
  self:stopUpdateTimer()
  self._timer = World.Timer(1, function()
    self:update(1)
    return true
  end)
end

function BastionManager:stopUpdateTimer()
  if self._timer and type(self._timer) == "function" then
    self._timer()
  end
end

function BastionManager:update(timeDelta)
  for index, bastion in pairs(self.bastionDict) do
    bastion:update(timeDelta)
  end
  if os.time() - self.lastClearStamp >= 1 then
    self:clearDeadBastion()
    self.lastClearStamp = os.time()
  end
end

function BastionManager:getBastionOperator(type)
  return self.operatorDict[type]
end

function BastionManager:getBastionDict()
  return self.bastionDict
end

function BastionManager:getBastion(uid)
  return self.bastionDict[uid]
end

function BastionManager:getBastionByOwnerID(ownerId)
  for i, bastion in pairs(self.bastionDict) do
    if bastion:getOwnerId() == ownerId then
      return bastion
    end
  end
  return nil
end

function BastionManager:setBastion(uid, bastion)
  if not uid then
    return
  end
  if not bastion then
    return
  end
  self.bastionDict[uid] = bastion
end

function BastionManager:removeBastion(uid)
  self.bastionDict[uid] = nil
end

function BastionManager:addBastion(bastion)
  self:setBastion(bastion:getUid(), bastion)
end

function BastionManager:deleteBastion(bastion)
  self:removeBastion(bastion:getUid())
end

function BastionManager:loadBastions()
  if self.loaded then
    return
  end
  local bastions = BastionConfig:getAllCfgs()
  for i, bastion in pairs(bastions) do
    local param = {}
    param.uid = i
    param.facilities = {}
    param.facilities[Define.Bastion.Facility.Type.Reborn] = bastion.reborn
    param.facilities[Define.Bastion.Facility.Type.DoorSensor] = bastion.door
    param.facilities[Define.Bastion.Facility.Type.Closet] = bastion.closet
    param.facilities[Define.Bastion.Facility.Type.Armory] = bastion.armory
    param.facilities[Define.Bastion.Facility.Type.Vault] = bastion.vault
    param.facilities[Define.Bastion.Facility.Type.ToolKit] = bastion.toolkit
    param.facilities[Define.Bastion.Facility.Type.Garage] = bastion.garage
    param.facilities[Define.Bastion.Facility.Type.Park] = bastion.park
    param.facilities[Define.Bastion.Facility.Type.DoorPlate] = bastion.doorplate
    local inOffset = Vector3.new(0, 0, -0.5)
    local outOffset = Vector3.new(0, 0, 0.5)
    local rootPosition = bastion.door.position
    local rootRotation = bastion.door.rotation
    Lib.rotate(outOffset, Vector3.new(-rootRotation.x, -rootRotation.y, -rootRotation.z))
    Lib.rotate(inOffset, Vector3.new(-rootRotation.x, -rootRotation.y, -rootRotation.z))
    local inPosition = rootPosition + inOffset
    local outPosition = rootPosition + outOffset
    local outDoorConfig = Lib.copy(bastion.door)
    local inDoorConfig = Lib.copy(bastion.door)
    outDoorConfig.position = outPosition
    inDoorConfig.position = inPosition
    param.facilities[Define.Bastion.Facility.Type.OutDoorTrigger] = outDoorConfig
    param.facilities[Define.Bastion.Facility.Type.InDoorTrigger] = inDoorConfig
    local bastion = BastionHome.new(param)
    self:addBastion(bastion)
  end
  self.loaded = true
end

function BastionManager:distributeBastion(ownerId)
  if not ownerId then
    return
  end
  self:clearDeadBastion()
  local theBastion
  for i, bastion in pairs(self.bastionDict) do
    if bastion:getOwnerId() == nil then
      bastion:setOwnerId(ownerId)
      theBastion = bastion
      local owner = Game.GetPlayerByUserId(bastion:getOwnerId())
      if owner and owner:isValid() and owner.isPlayer then
        local homeParam = {}
        local doorInfo = bastion:getFacility(Define.Bastion.Facility.Type.DoorSensor)
        local rebornInfo = bastion:getFacility(Define.Bastion.Facility.Type.Reborn)
        local config = World.cfg.bastionSetting or {}
        local reborn = config.reborn or {}
        local homeEffectName = reborn.effectName or "g2055_reborn_effect.effect"
        local homeOffset = reborn.offset or Vector3.new(0, 0, 0)
        local cloneHoneOffset = Lib.copy(homeOffset)
        Lib.rotate(cloneHoneOffset, Vector3.new(-doorInfo.rotation.x, -doorInfo.rotation.y, -doorInfo.rotation.z))
        homeParam.effectName = homeEffectName
        homeParam.position = rebornInfo.position + cloneHoneOffset
        homeParam.rotation = rebornInfo.rotation
        owner:S2C_CreateHomeMark(homeParam)
        local doorParam = {}
        local config = World.cfg.bastionSetting or {}
        local defense = config.defense or {}
        local defenseOffset = defense.offset or Vector3.new(1.28, 4, 0.5)
        local cloneDoorOffset = Lib.copy(defenseOffset)
        Lib.rotate(cloneDoorOffset, Vector3.new(-doorInfo.rotation.x, -doorInfo.rotation.y, -doorInfo.rotation.z))
        doorParam.position = doorInfo.position + cloneDoorOffset
        doorParam.rotation = doorInfo.rotation
        owner:S2C_SendDoorPos(doorInfo)
        owner:S2C_CreateDoorMark(doorParam)
        local parkInfo = bastion:getFacility(Define.Bastion.Facility.Type.Park)
        local park = config.park or {}
        local parkEffectName = park.effectName or "g2055_parking_effect.effect"
        local parkOffset = park.offset or Vector3.new(0, 0, 0)
        local cloneHoneOffset = Lib.copy(parkOffset)
        Lib.rotate(cloneHoneOffset, parkInfo.rotation)
        local parkParam = {}
        parkParam.effectName = parkEffectName
        parkParam.position = parkInfo.position + cloneHoneOffset
        parkParam.rotation = parkInfo.rotation
        owner:S2C_CreateParkMark(parkParam)
      end
      break
    end
  end
  return theBastion
end

function BastionManager:distributeBastionGM(ownerId, bastionId)
  if not ownerId then
    return
  end
  local theBastion
  if bastionId then
    theBastion = self:getBastion(bastionId)
  end
  if theBastion then
    local bastion = theBastion
    bastion:setOwnerId(ownerId)
    local owner = Game.GetPlayerByUserId(bastion:getOwnerId())
    if owner and owner:isValid() and owner.isPlayer then
      local homeParam = {}
      local doorInfo = bastion:getFacility(Define.Bastion.Facility.Type.DoorSensor)
      local rebornInfo = bastion:getFacility(Define.Bastion.Facility.Type.Reborn)
      local config = World.cfg.bastionSetting or {}
      local reborn = config.reborn or {}
      local homeEffectName = reborn.effectName or "g2055_reborn_effect.effect"
      local homeOffset = reborn.offset or Vector3.new(0, 0, 0)
      local cloneHoneOffset = Lib.copy(homeOffset)
      Lib.rotate(cloneHoneOffset, Vector3.new(-doorInfo.rotation.x, -doorInfo.rotation.y, -doorInfo.rotation.z))
      homeParam.effectName = homeEffectName
      homeParam.position = rebornInfo.position + cloneHoneOffset
      homeParam.rotation = rebornInfo.rotation
      owner:S2C_CreateHomeMark(homeParam)
      local doorParam = {}
      local config = World.cfg.bastionSetting or {}
      local defense = config.defense or {}
      local defenseOffset = defense.offset or Vector3.new(1.28, 4, 0.5)
      local cloneDoorOffset = Lib.copy(defenseOffset)
      Lib.rotate(cloneDoorOffset, Vector3.new(-doorInfo.rotation.x, -doorInfo.rotation.y, -doorInfo.rotation.z))
      doorParam.position = doorInfo.position + cloneDoorOffset
      doorParam.rotation = doorInfo.rotation
      owner:S2C_SendDoorPos(doorInfo)
      owner:S2C_CreateDoorMark(doorParam)
      local parkInfo = bastion:getFacility(Define.Bastion.Facility.Type.Park)
      local park = config.park or {}
      local parkEffectName = park.effectName or "g2055_parking_effect.effect"
      local parkOffset = park.offset or Vector3.new(0, 0, 0)
      local cloneHoneOffset = Lib.copy(parkOffset)
      Lib.rotate(cloneHoneOffset, parkInfo.rotation)
      local parkParam = {}
      parkParam.effectName = parkEffectName
      parkParam.position = parkInfo.position + cloneHoneOffset
      parkParam.rotation = parkInfo.rotation
      owner:S2C_CreateParkMark(parkParam)
    end
  end
  return theBastion
end

function BastionManager:clearDeadBastion()
  for _, bastion in pairs(self.bastionDict) do
    local ownerId = bastion:getOwnerId()
    if ownerId ~= nil then
      local owner = Game.GetPlayerByUserId(ownerId)
      if not owner or not owner:isValid() then
        bastion:setOwnerId(nil)
        self.clearDeadBastionCounter = self.clearDeadBastionCounter + 1
        print("****************************************************************** clearDeadBastion :", self.clearDeadBastionCounter)
      end
    end
  end
end

function BastionManager:releaseBastion(ownerId)
  if not ownerId then
    return
  end
  for i, bastion in pairs(self.bastionDict) do
    if bastion:getOwnerId() == ownerId then
      local owner = Game.GetPlayerByUserId(ownerId)
      if owner and owner:isValid() and owner.isPlayer then
        owner:S2C_RemoveHomeMark()
        owner:S2C_RemoveParkMark()
        owner:S2C_RemoveDoorMark()
      end
      bastion:setOwnerId(nil)
    end
  end
end

function BastionManager:responsePlayerDie(playerId)
  if not playerId then
    return
  end
  for i, bastion in pairs(self.bastionDict) do
    bastion:onPlayerDie(playerId)
  end
end

function BastionManager:getPlayerBastion(player)
  if not player then
    return
  end
  if not player:isValid() then
    return
  end
  local bastion = self:getBastionByOwnerID(player.platformUserId)
  if not bastion then
    bastion = self:distributeBastion(player.platformUserId)
    if not bastion then
      player.loginFail = true
      Game.SendStartGame()
      Game.KickOutPlayer(player)
      self.noEmptyBastionKickCounter = self.noEmptyBastionKickCounter + 1
      print("++++++++++++++++++++++++++++++++++++++++++++++ noEmptyBastionKickCounter :", self.noEmptyBastionKickCounter)
      return
    end
    player:bhp_setBastionPosition(bastion:getWorldPosition())
  end
  return bastion
end

function BastionManager:releasePlayerBastion(player)
  if not player then
    return
  end
  if not player:isValid() then
    return
  end
  self:releaseBastion(player.platformUserId)
  player:bhp_setBastionPosition(Vector3.new(0, 0, 0))
end

function BastionManager:operateBastionFacility(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.ParamWrong
  result.msg = "Param Error"
  local facilityType = param.type
  if not facilityType then
    return result
  end
  local ownerId = param.ownerId
  if not ownerId then
    return result
  end
  local manner = param.manner
  if not manner then
    return result
  end
  local operatorId = param.operatorId
  if not operatorId then
    return result
  end
  local operator = self:getBastionOperator(facilityType)
  if not operator then
    result.status = Define.Bastion.Facility.OperateErrorCode.UnknownFacility
    result.msg = "unknown facility type:" .. (facilityType or "unknown")
    return result
  end
  return operator:operate(param)
end

return BastionManager

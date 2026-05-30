local BastionUtils = require("common.bastion_utils")
local ClothesConfig = T(Config, "ClothesConfig")
local DoorsConfig = T(Config, "DoorsConfig")
local WeaponConfig = T(Config, "WeaponConfig")
local BastionManager = require("server.bastion_manager")
local PlayerBastionServer = EntityServerPlayer

function PlayerBastionServer:initBastion()
  self:getBastion()
  self:initVault()
  self:initCloset()
  self:initDefense()
  self:initGarage()
  self:initArmory()
end

function PlayerBastionServer:initVault()
  local player = self
  local createTime = player:getBastionVaultCreateTime()
  if createTime <= 0 then
    local config = World.cfg.bastionSetting or {}
    local vault = config.vault or {}
    local balance = vault.bornBalance or 0
    player:setBastionCurrency(Define.Bastion.Currency.Type.Gold, balance)
    player:setBastionVaultCreateTime(os.time())
  end
end

function PlayerBastionServer:initCloset()
  local player = self
  local createTime = player:getBastionClosetCreateTime()
  if createTime <= 0 then
    local config = World.cfg.bastionSetting or {}
    local closet = config.closet or {}
    local bornClothes = closet.bornClothes or {}
    for i, id in pairs(bornClothes) do
      player:addBastionClothesItem({id = id})
    end
    player:setBastionClosetCreateTime(os.time())
  end
  local config = World.cfg.bastionSetting or {}
  local closet = config.closet or {}
  local bornClothes = closet.loginGetClothes or {}
  for i, id in pairs(bornClothes) do
    player:addBastionClothesItem({id = id})
  end
end

function PlayerBastionServer:initDefense()
  local player = self
  local createTime = player:getBastionDefenseCreateTime()
  if createTime <= 0 then
    local config = World.cfg.bastionSetting or {}
    local defense = config.defense or {}
    local bornDefense = defense.bornDefense or {}
    for type, id in pairs(bornDefense) do
      player:changeBastionDefense(type, id)
    end
    player:setBastionDefenseCreateTime(os.time())
  end
end

function PlayerBastionServer:initGarage()
  local player = self
  local createTime = player:getBastionGarageCreateTime()
  if createTime <= 0 then
    local config = World.cfg.bastionSetting or {}
    local garage = config.garage or {}
    local bornCars = garage.bornCars or {}
    for index, id in pairs(bornCars) do
      local item = {id = id}
      player:setBastionCarItem(1, item)
    end
    player:setBastionGarageCreateTime(os.time())
  end
end

function PlayerBastionServer:initArmory()
  local player = self
  local createTime = player:getBastionArmoryCreateTime()
  if createTime <= 0 then
    local config = World.cfg.bastionSetting or {}
    local armory = config.armory or {}
    local bornWeapons = armory.bornWeapons or {}
    for index, id in pairs(bornWeapons) do
      local config = WeaponConfig:getCfgById(id)
      if config then
        local item = {
          id = id,
          bulletCount = config.bulletCount
        }
        player:addBastionArmoryItem(item)
      end
    end
    player:setBastionArmoryCreateTime(os.time())
  end
end

function PlayerBastionServer:getBastion()
  return BastionManager.Instance():getPlayerBastion(self)
end

function PlayerBastionServer:releaseBastion()
  return BastionManager.Instance():releasePlayerBastion(self)
end

function PlayerBastionServer:triggerBastionDefense(operateType, ownerId, operatorId, defenseType, from, objId)
  local owner = Game.GetPlayerByUserId(ownerId)
  if not owner then
    return
  end
  local home = owner:getBastion()
  if not home then
    return
  end
  local defenseInfo = home:getDefense(defenseType)
  if not defenseInfo then
    return
  end
  local doorEntity = defenseInfo.entity
  if not doorEntity or not doorEntity:isValid() then
    return
  end
  local status = doorEntity:bdp_getStatus()
  if status == Define.Bastion.Defense.Status.Normal then
    if from == "InDoor" then
      if operateType == "Open" then
        if owner:checkOutHome() then
          doorEntity:brp_addHoldDoorCount(1)
          self:sendPacket({
            pid = "playerOutHome"
          })
        end
      elseif operateType == "Close" then
        doorEntity:brp_delHoldDoorCount(1)
      end
    elseif from == "OutDoor" then
      if operateType == "Open" then
        if operatorId == ownerId then
          doorEntity:brp_addHoldDoorCount(1)
        end
      elseif operateType == "Close" then
        doorEntity:brp_delHoldDoorCount(1)
      end
    end
  elseif status == Define.Bastion.Defense.Status.Hacked then
    if operateType == "Open" then
      doorEntity:brp_addHoldDoorCount(1)
    else
      if operateType == "Close" then
        doorEntity:brp_delHoldDoorCount(1)
      else
      end
    end
  end
end

function PlayerBastionServer:canChangeBastionDefense(type)
  local player = self
  local currentItem = player:getBastionDefenseItem(type)
  if currentItem then
    local property = currentItem.propertyDict or {}
    local status = property.status or Define.Bastion.Defense.Status.None
    if status == Define.Bastion.Defense.Status.Hacked or status == Define.Bastion.Defense.Status.Normal then
      return true
    end
  else
    return true
  end
  return false
end

function PlayerBastionServer:changeBastionDefense(type, id)
  if not self:canChangeBastionDefense(type) then
    return
  end
  local player = self
  local config = DoorsConfig:getCfgById(id)
  if config then
    local item = {}
    item.id = config.id
    local property = {}
    property.id = config.id
    property.hp = config.maxHp
    property.status = Define.Bastion.Defense.Status.Normal
    property.statusTimeStamp = os.time()
    item.propertyDict = property
    player:setBastionDefenseItem(type, item)
    local bastion = self:getBastion()
    if not bastion then
      return false
    end
    bastion:changeDefense(type, item)
    return true
  end
  return false
end

local facilityTypeToAreaTypeDict = {}
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.Armory] = Define.EventTracking.Area.Bastion.Armory
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.Closet] = Define.EventTracking.Area.Bastion.Closet
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.Vault] = Define.EventTracking.Area.Bastion.Vault
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.Garage] = Define.EventTracking.Area.Bastion.Garage
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.Park] = Define.EventTracking.Area.Bastion.Park
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.ToolKit] = Define.EventTracking.Area.Bastion.Toolkit
facilityTypeToAreaTypeDict[Define.Bastion.Facility.Type.DoorSensor] = Define.EventTracking.Area.Bastion.Door
local defenseStatusToReportStatusDict = {}
defenseStatusToReportStatusDict[Define.Bastion.Defense.Status.Damaged] = 1
defenseStatusToReportStatusDict[Define.Bastion.Defense.Status.Hacked] = 2
defenseStatusToReportStatusDict[Define.Bastion.Defense.Status.Normal] = 3

function PlayerBastionServer:S2C_TriggerBastionFacility(param)
  local packet = {
    pid = "S2C_TriggerBastionFacility",
    operateType = param.operateType or Define.Bastion.Facility.TriggerType.None,
    facilityType = param.facilityType,
    ownerId = param.ownerId,
    operatorId = param.operatorId,
    objID = param.objID,
    triggerParam = param.triggerParam
  }
  self:sendPacket(packet)
  local evtType = param.operateType or Define.Bastion.Facility.TriggerType.None
  if evtType == Define.Bastion.Facility.TriggerType.Open then
    self:evt_startStayArea()
    local facilityType = param.facilityType or Define.Bastion.Facility.Type.None
    local areaType = facilityTypeToAreaTypeDict[facilityType]
    if not areaType then
      return
    end
    local reportData = {area_type = areaType}
    local ownerId = param.ownerId
    reportData.house_owner = ownerId
    local owner = Game.GetPlayerByUserId(ownerId)
    if owner and owner:isValid() and owner.isPlayer then
      reportData.team_id = owner:getGangId()
      local doorItem = owner:getBastionDefenseItem(Define.Bastion.Defense.Type.Door)
      if doorItem then
        reportData.door_type = doorItem.id
        reportData.door_hp = doorItem.propertyDict.hp
        reportData.status = defenseStatusToReportStatusDict[doorItem.propertyDict.status]
      end
    end
    self:evt_reportEvent(Define.EventTracking.Type.EnterArea, reportData)
  elseif evtType == Define.Bastion.Facility.TriggerType.Close then
    local facilityType = param.facilityType or Define.Bastion.Facility.Type.None
    local areaType = facilityTypeToAreaTypeDict[facilityType]
    if not areaType then
      return
    end
    local reportData = {
      area_type = areaType,
      stay_time = self:evt_getStayAreaTime()
    }
    self:evt_reportEvent(Define.EventTracking.Type.ExitArea, reportData)
  end
end

function PlayerBastionServer:S2C_TriggerBastionPark(param)
  local packet = {
    pid = "S2C_TriggerBastionPark",
    operateType = param.operateType or Define.Bastion.Facility.TriggerType.None,
    facilityType = param.facilityType,
    ownerId = param.ownerId,
    operatorId = param.operatorId,
    objID = param.objID,
    triggerParam = param.triggerParam
  }
  self:sendPacket(packet)
  local evtType = param.operateType or Define.Bastion.Facility.TriggerType.None
  if evtType == Define.Bastion.Facility.TriggerType.Open then
    self:evt_startStayArea()
    local facilityType = param.facilityType or Define.Bastion.Facility.Type.None
    local areaType = facilityTypeToAreaTypeDict[facilityType]
    if not areaType then
      return
    end
    local reportData = {area_type = areaType}
    local ownerId = param.ownerId
    reportData.house_owner = ownerId
    local owner = Game.GetPlayerByUserId(ownerId)
    if owner and owner:isValid() and owner.isPlayer then
      reportData.team_id = owner:getGangId()
      local doorItem = owner:getBastionDefenseItem(Define.Bastion.Defense.Type.Door)
      if doorItem then
        reportData.door_type = doorItem.id
        reportData.door_hp = doorItem.propertyDict.hp
        reportData.status = defenseStatusToReportStatusDict[doorItem.propertyDict.status]
      end
    end
    self:evt_reportEvent(Define.EventTracking.Type.EnterArea, reportData)
  elseif evtType == Define.Bastion.Facility.TriggerType.Close then
    local facilityType = param.facilityType or Define.Bastion.Facility.Type.None
    local areaType = facilityTypeToAreaTypeDict[facilityType]
    if not areaType then
      return
    end
    local reportData = {
      area_type = areaType,
      stay_time = self:evt_getStayAreaTime()
    }
    self:evt_reportEvent(Define.EventTracking.Type.ExitArea, reportData)
  end
end

function PlayerBastionServer:S2C_CreateHomeMark(param)
  local packet = {
    pid = "S2C_CreateHomeMark",
    effectName = param.effectName,
    position = param.position,
    rotation = param.rotation
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_RemoveHomeMark(param)
  local packet = {
    pid = "S2C_RemoveHomeMark"
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_CreateParkMark(param)
  local packet = {
    pid = "S2C_CreateParkMark",
    effectName = param.effectName,
    position = param.position,
    rotation = param.rotation
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_RemoveParkMark(param)
  local packet = {
    pid = "S2C_RemoveParkMark"
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_CreateDoorMark(param)
  local packet = {
    pid = "S2C_CreateDoorMark",
    position = param.position,
    rotation = param.rotation,
    objID = param.objID
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_SendDoorPos(param)
  local player = self
  local createTime = player:getBastionClosetCreateTime()
  if createTime <= 0 then
    player:setOpenGuide()
  end
  local packet = {
    pid = "S2C_SendDoorPos",
    position = param.position,
    rotation = param.rotation,
    objID = param.objID
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_RemoveDoorMark(param)
  local packet = {
    pid = "S2C_RemoveDoorMark"
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_PlayBastionEffect(param)
  local packet = {
    pid = "S2C_PlayBastionEffect",
    effectName = param.effectName,
    position = param.position,
    timeScale = param.timeScale,
    bodyScale = param.bodyScale,
    yaw = param.yaw,
    duration = param.duration
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:S2C_ShowBastionDefenseTips(param)
  local packet = {
    pid = "S2C_ShowBastionDefenseTips",
    type = param.type,
    attackerName = param.attackerName
  }
  self:sendPacket(packet)
end

function PlayerBastionServer:bst_CancelHack()
  local hackObjID = self:bhp_getHackObjID()
  if hackObjID then
    local door = World.CurWorld:getObject(hackObjID)
    if door and door:isValid() then
      door:bdp_cancelHack(self.platformUserId)
    end
  end
end

function PlayerBastionServer:bst_ConfirmHack()
  local hackObjID = self:bhp_getHackObjID()
  if hackObjID then
    local door = World.CurWorld:getObject(hackObjID)
    if door and door:isValid() then
      door:bdp_confirmHack(self.platformUserId)
    end
  end
end

function PlayerBastionServer:bst_ReportOperateFacility(operationName)
  local reportData = {}
  reportData.operation_name = operationName
  reportData.stored_coins = self:getBastionCurrency(Define.Bastion.Currency.Type.Gold)
  local clothesData = ""
  local clothesDict = self:getBastionClothesDict()
  for i, item in pairs(clothesDict) do
    clothesData = clothesData .. item.id .. ","
  end
  reportData.stored_cloth_info_g2055 = clothesData
  local armoryData = ""
  local armoryDict = self:getBastionArmoryDict()
  for i, item in pairs(armoryDict) do
    armoryData = armoryData .. item.id .. ","
  end
  reportData.stored_arms_info_g2055 = armoryData
  local carData = ""
  local carDict = self:getBastionCarDict()
  for i, item in pairs(carDict) do
    carData = carData .. item.id .. ","
  end
  reportData.stored_cars_info_g2055 = carData
  local doorItem = self:getBastionDefenseItem(Define.Bastion.Defense.Type.Door)
  reportData.door_hp = doorItem.propertyDict.hp or 0
  reportData.door_id = doorItem.id
  self:evt_reportEvent(Define.EventTracking.Type.OperateFacility, reportData)
end

function PlayerBastionServer:bst_ReportHackDoor(operate, ownerId)
  local reportData = {}
  reportData.status = operate
  reportData.house_owner = ownerId
  local owner = Game.GetPlayerByUserId(ownerId)
  if owner and owner:isValid() then
    reportData.team_id = owner:getGangId()
    local doorItem = owner:getBastionDefenseItem(Define.Bastion.Defense.Type.Door)
    if doorItem then
      reportData.door_type = doorItem.id
      reportData.door_hp = doorItem.propertyDict.hp
    end
  end
  self:evt_reportEvent(Define.EventTracking.Type.HackDoor, reportData)
end

function PlayerBastionServer:bst_ReportGainItem(manner, itemType, itemID, deltaAmount, currentAmount)
  local reportData = {}
  reportData.access_type = manner
  reportData.item_type = itemType
  reportData.item_id = itemID
  reportData.gain_amount = deltaAmount
  reportData.current_num = currentAmount
  self:evt_reportEvent(Define.EventTracking.Type.GainItem, reportData)
end

function PlayerBastionServer:bst_ReportLoseItem(manner, itemType, itemID, deltaAmount, currentAmount)
  local reportData = {}
  reportData.access_type_drop = manner
  reportData.item_type = itemType
  reportData.item_id = itemID
  reportData.drop_amount = deltaAmount
  reportData.current_num = currentAmount
  self:evt_reportEvent(Define.EventTracking.Type.LoseItem, reportData)
end

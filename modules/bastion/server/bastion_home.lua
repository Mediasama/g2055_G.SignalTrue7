local DoorsConfig = T(Config, "DoorsConfig")
local BastionUtils = require("common.bastion_utils")
local BastionBase = require("server.bastion_base")
local BastionHome = Lib.class("BastionHome", BastionBase)

function BastionHome:ctor(param)
  BastionBase.ctor(self, param)
  self._type = Define.Bastion.Type.Home
  self._facilities = {}
  self._defense = {}
  local map = World.CurWorld:getMap()
  for type, facilityInfo in pairs(param.facilities) do
    local position = Lib.copy(facilityInfo.position)
    local rotation = Lib.copy(facilityInfo.rotation)
    local config = BastionUtils.Instance():getFacilityConfig(type)
    if config.cfgName then
      local trigger = EntityServer.Create({
        cfgName = config.cfgName,
        map = map,
        pos = position,
        ry = rotation.y,
        rp = rotation.x,
        rr = rotation.z
      })
      trigger:setRotation(rotation.y, rotation.x, rotation.z)
      trigger:setFacilityCfgID(param.uid)
      self:addFacility(type, facilityInfo.position, facilityInfo.rotation, trigger)
    end
  end
  self._owner_id = nil
end

function BastionHome:getOwnerId()
  return self._owner_id
end

function BastionHome:setOwnerId(id)
  self._owner_id = id
  for propertyType, facilityInfo in pairs(self._facilities) do
    local trigger = facilityInfo.trigger
    if trigger then
      trigger:setBastionOwnerId(self:getOwnerId())
    end
  end
  self:reloadFacility()
  self:reloadDefense()
end

function BastionHome:getFacility(type)
  return self._facilities[type]
end

function BastionHome:addFacility(type, position, rotation, trigger)
  local facilityInfo = {}
  facilityInfo.position = position
  facilityInfo.rotation = rotation
  facilityInfo.trigger = trigger
  trigger:setBastionUid(self:getUid())
  trigger:setBastionFacilityType(type)
  self._facilities[type] = facilityInfo
end

function BastionHome:getWorldPosition()
  local rebornInfo = self:getFacility(Define.Bastion.Facility.Type.Reborn)
  if rebornInfo then
    return rebornInfo.position, rebornInfo.rotation
  end
end

function BastionHome:getDefense(type)
  return self._defense[type]
end

function BastionHome:setDefense(type, item)
  if not item then
    return
  end
  local ownerId = self:getOwnerId()
  if not ownerId then
    return
  end
  local player = Game.GetPlayerByUserId(ownerId)
  if not player then
    return
  end
  local defenseId = item.id
  local configItem = DoorsConfig:getCfgById(defenseId)
  if not configItem then
    return
  end
  local entityCfg = configItem.entityCfg
  local map = World.CurWorld:getMap()
  local doorInfo = self:getFacility(Define.Bastion.Facility.Type.DoorSensor)
  if not doorInfo then
    return
  end
  local position = doorInfo.position
  local rotation = doorInfo.rotation
  local entity = EntityServer.Create({
    cfgName = entityCfg,
    map = map,
    pos = position,
    ry = rotation.y,
    rp = rotation.x,
    rr = rotation.z
  })
  entity:setBastionOwnerId(ownerId)
  entity:setBastionUid(self:getUid())
  entity:setBastionDefenseType(type)
  entity:brp_reloadDefensePropertyCopy()
  entity:brp_setHoldDoorCount(0)
  entity:brp_setInitRotation(rotation)
  entity:setRotation(rotation.y, rotation.x, rotation.z)
  entity:syncPosDelay(1)
  self._defense[type] = {id = defenseId, entity = entity}
end

function BastionHome:removeDefense(type)
  local defenseInfo = self:getDefense(type)
  if defenseInfo then
    local entity = defenseInfo.entity
    if entity and entity:isValid() then
      entity:brp_clearHackInfoDict()
      entity:destroy()
    end
  end
  self._defense[type] = nil
end

function BastionHome:changeDefense(type, item)
  local defenseInfo = self:getDefense(type)
  if defenseInfo then
    local entity = defenseInfo.entity
    if entity and entity:isValid() then
      local hackDict = entity:brp_getHackInfoDict()
      for i, hackInfo in pairs(hackDict) do
        local player = Game.GetPlayerByUserId(hackInfo.operatorId)
        if player and player:isValid() and player.isPlayer then
          local param = {}
          param.type = Define.Bastion.Defense.Tips.Type.OwnerUpdate
          player:S2C_ShowBastionDefenseTips(param)
        end
      end
    end
  end
  self:removeDefense(type)
  self:setDefense(type, item)
end

function BastionHome:clearDefense()
  local types = {}
  for type, defenseInfo in pairs(self._defense) do
    table.insert(types, type)
  end
  for i, type in pairs(types) do
    self:removeDefense(type)
  end
  self._defense = {}
end

function BastionHome:reloadFacility()
  local armory = self:getFacility(Define.Bastion.Facility.Type.Armory)
  if armory then
    local trigger = armory.trigger
    if trigger and trigger:isValid() then
      local ownerId = self:getOwnerId()
      if ownerId then
        local player = Game.GetPlayerByUserId(ownerId)
        if player then
          local armoryLevel = player:getBastionArmoryLevel()
          if 0 < armoryLevel then
            local config = World.cfg.bastionSetting or {}
            local armory = config.armory or {}
            local actorName = armory.actorName or "g2055_house_weapon.actor"
            trigger:changeActor(actorName)
          else
            trigger:changeActor("blank.actor")
          end
        else
          trigger:changeActor("blank.actor")
        end
      else
        trigger:changeActor("blank.actor")
      end
    end
  end
  local garage = self:getFacility(Define.Bastion.Facility.Type.Garage)
  if garage then
    local trigger = garage.trigger
    if trigger and trigger:isValid() then
      local ownerId = self:getOwnerId()
      if ownerId then
        local player = Game.GetPlayerByUserId(ownerId)
        if player then
          local garageLevel = player:getBastionGarageLevel()
          if 0 < garageLevel then
            local config = World.cfg.bastionSetting or {}
            local garage = config.garage or {}
            local actorName = garage.actorName or "g2055_door_vehicle.actor"
            trigger:changeActor(actorName)
          else
            trigger:changeActor("blank.actor")
          end
        else
          trigger:changeActor("blank.actor")
        end
      else
        trigger:changeActor("blank.actor")
      end
    end
  end
end

function BastionHome:reloadDefense()
  self:clearDefense()
  local ownerId = self:getOwnerId()
  if not ownerId then
    return
  end
  local player = Game.GetPlayerByUserId(ownerId)
  if not player then
    return
  end
  local defenseDict = player:getBastionDefenseDict()
  for type, item in pairs(defenseDict) do
    self:changeDefense(type, item)
  end
end

function BastionHome:updateDefense(timeDelta)
  for i, defenseInfo in pairs(self._defense) do
    local entity = defenseInfo.entity
    if entity and entity:isValid() then
      entity:bdp_update()
    end
  end
end

function BastionHome:update(timeDelta)
  self:updateDefense(timeDelta)
end

function BastionHome:onPlayerDie(playerId)
  for i, defenseInfo in pairs(self._defense) do
    local entity = defenseInfo.entity
    if entity and entity:isValid() then
      entity:bdp_onPlayerDie(playerId)
    end
  end
end

return BastionHome

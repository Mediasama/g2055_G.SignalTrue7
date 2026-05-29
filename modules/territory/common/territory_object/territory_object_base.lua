local GangsServer = T(Lib, "GangsServer")
local TerritoryIncomeConfig = T(Config, "TerritoryIncomeConfig")
local GangsManager = require("server.gangs_manager_server")
local TerritoryConfig = T(Config, "TerritoryConfig")
local TerritoryObjectBase = Lib.class("TerritoryObjectBase")
local GangIconConfig = T(Config, "GangIconConfig")
local m_AreaManager

function TerritoryObjectBase:ctor(entity, id)
  self:init(entity)
  self.territoryData = {
    objID = entity.objID,
    owner = nil,
    ownerType = nil,
    awardCoin = 0
  }
  self.provideAwardTimes = 0
  self.triggerPlayer = {}
  local cfg = TerritoryConfig:getCfgById(id)
  self.cfg = cfg
end

function TerritoryObjectBase:getOccupyInfo()
  local data = {
    id = self.cfg.id,
    name = self.entity:getValue("territoryOwner").name,
    gangLogoId = self:getGangIcon(),
    owner = self.territoryData.owner,
    ownerType = self.territoryData.ownerType,
    awardCoin = self.territoryData.awardCoin,
    objID = self.territoryData.objID
  }
  return data
end

function TerritoryObjectBase:getGangTerritoryId(gangId)
  if self.territoryData.ownerType == Define.TerritoryOwnerType.Gang and self.territoryData.owner == gangId then
    return self.cfg.id
  end
  return nil
end

function TerritoryObjectBase:getGangIcon()
  if self.territoryData.owner == nil then
    return nil
  elseif self.territoryData.ownerType == Define.TerritoryOwnerType.Player then
    return nil
  else
    local gangId = self.territoryData.owner
    local gangMgr = GangsManager:getInstance()
    local gang
    gang = gangMgr:getGang(gangId)
    if gang then
      return gang.logoId
    end
  end
end

function TerritoryObjectBase:setOccupyByPlayer(player)
  self:notifyTerritorySwitchOwner(Define.TerritoryOwnerType.Player, player.name)
  if self.territoryData.ownerType == Define.TerritoryOwnerType.Gang then
    GangsServer:export_reportGangTerritoryChange(self.territoryData.ownerType, false)
  end
  self.territoryData.owner = player.platformUserId
  self.territoryData.ownerType = Define.TerritoryOwnerType.Player
end

function TerritoryObjectBase:setOccupyByGang(gangId, enterGang, player)
  local gangMgr = GangsManager:getInstance()
  local gang
  gang = gangMgr:getGang(gangId)
  if gang then
    self:notifyTerritorySwitchOwner(Define.TerritoryOwnerType.Gang, gang.name, enterGang)
  end
  if self.territoryData.ownerType == Define.TerritoryOwnerType.Gang then
    GangsServer:export_reportGangTerritoryChange(self.territoryData.ownerType, false)
    GangsServer:export_gangTerritoryChange(self.territoryData.owner, self.cfg.id, false)
  end
  self.territoryData.owner = gangId
  self.territoryData.ownerType = Define.TerritoryOwnerType.Gang
  self.territoryData.occupyPlayerUserId = player.platformUserId
  GangsServer:export_reportGangTerritoryChange(gangId, true)
  GangsServer:export_gangTerritoryChange(gangId, self.cfg.id, true)
end

function TerritoryObjectBase:notifyTerritorySwitchOwner(type, name, enterGang)
  if self.territoryData.owner then
    if self.territoryData.ownerType == Define.TerritoryOwnerType.Player then
      local player = Game.GetPlayerByUserId(self.territoryData.owner)
      if player and player:isValid() then
        player:notifyTerritorySwitchOwner(name, type, self.cfg.name, enterGang)
      end
    else
      local gangId = self.territoryData.owner
      local gangMgr = GangsManager:getInstance()
      local gang
      gang = gangMgr:getGang(gangId)
      if gang then
        local memberList = gang.memberList
        for k, v in pairs(memberList) do
          local player = Game.GetPlayerByUserId(k)
          if player and player:isValid() then
            player:notifyTerritorySwitchOwner(name, type, self.cfg.name, enterGang)
          end
        end
      end
    end
  end
end

function TerritoryObjectBase:clearOccupyData()
  self.territoryData.owner = nil
  self.territoryData.ownerType = nil
  self.provideAwardSuccessTime = nil
  self.occupyingData = nil
  self:updateEntityTerritoryOwner()
  self.entity:setValue("inComeProcessInfo", {visible = false})
  self.entity:setValue("territoryOwner", {})
  self:notifyUpdateArea()
end

function TerritoryObjectBase:updateEntityTerritoryOwner()
  local actorName = self.entity:cfg().actorName
  if self.territoryData.owner == nil then
    self.entity:setValue("territoryOwner", {})
  elseif self.territoryData.ownerType == Define.TerritoryOwnerType.Player then
    local player = Game.GetPlayerByUserId(self.territoryData.owner)
    self.entity:setValue("territoryOwner", {
      owner = self.territoryData.owner,
      name = player.name
    })
  else
    local gangId = self.territoryData.owner
    local gangMgr = GangsManager:getInstance()
    local gang
    gang = gangMgr:getGang(gangId)
    if gang then
      self.entity:setValue("territoryOwner", {
        owner = gangId,
        name = gang.name
      })
      local entity_actor = GangIconConfig:getGangFlagActor(gang.logoId)
      if entity_actor then
        actorName = entity_actor
      end
    end
  end
  self.entity:changeActor(actorName)
end

function TerritoryObjectBase:init(entity)
  self.entity = entity
end

function TerritoryObjectBase:getTerritoryData()
  return self.territoryData
end

function TerritoryObjectBase:recordTriggerPlayer(player, operateType)
  if operateType == Define.TerritoryTriggerType.Enter then
    self.triggerPlayer[player.platformUserId] = true
  else
    self:interruptTerritoryOccupy(player)
    self.triggerPlayer[player.platformUserId] = nil
  end
end

function TerritoryObjectBase:getAward(player, gangId)
  if not self.triggerPlayer[player.platformUserId] then
    return
  end
  if gangId ~= self.territoryData.owner then
    return
  end
  local coins = self.territoryData.awardCoin
  local occupyPlayerUserId = self.territoryData.occupyPlayerUserId
  self:setAwardCoin(0)
  player:updateOccupyInfo(self.cfg.id, self:getOccupyInfo())
  self.provideAwardTimes = 0
  return {
    coins = coins,
    userId = occupyPlayerUserId,
    id = self.cfg.id
  }
end

function TerritoryObjectBase:countAward()
  local playerNumber = 0
  local players = Game.GetAllPlayers() or {}
  for _, player in pairs(players) do
    if player and player:isValid() then
      playerNumber = playerNumber + 1
    end
  end
  local data = TerritoryIncomeConfig:getIncomeDelta(self.cfg.id, playerNumber)
  return math.floor(data * self.cfg.basic_income)
end

function TerritoryObjectBase:setAwardCoin(coin)
  self.territoryData.awardCoin = coin
  self:notifyUpdateArea()
end

function TerritoryObjectBase:notifyUpdateArea()
  if m_AreaManager == nil then
    m_AreaManager = require("server.area_manager_server")
  end
  m_AreaManager:getInstance():updateAreaTerritoryInfo(self.cfg.id)
end

function TerritoryObjectBase:provideAward()
  if self.territoryData.owner == nil then
    return false
  end
  if self.provideAwardTimes >= self.cfg.max_income then
    return true
  end
  self:setAwardCoin(self.territoryData.awardCoin + self:countAward())
  self.provideAwardTimes = self.provideAwardTimes + 1
  return true
end

function TerritoryObjectBase:setProvideAwardSuccessTime()
  self.provideAwardSuccessTime = self.cfg.income_time + World:Now()
  self.entity:setValue("inComeProcessInfo", {
    visible = true,
    startTime = os.time(),
    processTime = self.cfg.income_time
  })
end

function TerritoryObjectBase:occupySuccess()
  self.provideAwardSuccessTime = nil
  local player = Game.GetPlayerByUserId(self.occupyingData.userId)
  if player and player:isValid() then
    local gangId = player:getGangId()
    if gangId then
      player:evt_territory_occupied(Define.TerritoryOperationType.Success, self.cfg.id, self:getTerritoryData())
      self:setOccupyByGang(gangId, false, player)
    else
      player:evt_territory_occupied(Define.TerritoryOperationType.Success, self.cfg.id, self:getTerritoryData())
      self:setOccupyByPlayer(player)
    end
    player:notifyOccupySuccess(self.cfg.id, self:getOccupyInfo())
    self:setProvideAwardSuccessTime()
    player:setPlayerOccupyBuff(false)
    self:updateEntityTerritoryOwner()
    self:notifyUpdateArea()
  end
  self.occupyingData = nil
end

function TerritoryObjectBase:playerRequestOccupy(player)
  if not self.triggerPlayer[player.platformUserId] then
    return Define.TerritoryPacketCode.ErrorRequest
  end
  local gangId = player:getGangId()
  if gangId == nil then
    return Define.TerritoryPacketCode.NeedAddGang
  end
  if self.occupyingData then
    local occupyingPlayer = Game.GetPlayerByUserId(self.occupyingData.userId)
    if occupyingPlayer and occupyingPlayer:isValid() then
      return Define.TerritoryPacketCode.OtherPlayerOccupying
    else
      self.occupyingData = nil
    end
  end
  if self:isSameCamp(player) then
    return Define.TerritoryPacketCode.SelfCamp
  end
  self.occupyingData = {
    userId = player.platformUserId,
    occupyingSuccessTime = World.Now() + self.cfg.occupy_time
  }
  player:evt_territory_occupied(Define.TerritoryOperationType.Start, self.cfg.id, self:getTerritoryData())
  player:pam_stopMotion()
  player:setPlayerOccupyBuff(true)
  return Define.TerritoryPacketCode.Success
end

function TerritoryObjectBase:isSameCamp(requestPlayer)
  if self.territoryData.owner and self.territoryData.owner == requestPlayer:getGangId() then
    return true
  end
  return false
end

function TerritoryObjectBase:updateStatus()
  if self.occupyingData and self.occupyingData.occupyingSuccessTime <= World.Now() then
    self:occupySuccess()
  end
  if self.provideAwardSuccessTime and self.provideAwardSuccessTime <= World.Now() then
    local result = self:provideAward()
    if result then
      self:setProvideAwardSuccessTime()
    end
  end
end

function TerritoryObjectBase:interruptTerritoryOccupy(player)
  if self.occupyingData and self.occupyingData.userId == player.platformUserId then
    player:evt_territory_occupied(Define.TerritoryOperationType.Interrupt, self.cfg.id, self:getTerritoryData())
    player:interruptTerritoryOccupy(self.entity.objID)
    self.occupyingData = nil
    player:setPlayerOccupyBuff(false)
  end
end

function TerritoryObjectBase:onPlayerLogout(player)
  self:recordTriggerPlayer(player, Define.TerritoryTriggerType.Exit)
  self:interruptTerritoryOccupy(player)
  if player:getGangId() == self.territoryData.owner and player.platformUserId == self.territoryData.occupyPlayerUserId then
    self.territoryData.occupyPlayerUserId = nil
  end
end

function TerritoryObjectBase:onGangDismiss(gangID)
  if gangID == self.territoryData.owner then
    self:clearOccupyData()
  end
end

function TerritoryObjectBase:enterGang(userId, gangId)
  if userId == self.territoryData.owner then
    self:setOccupyByGang(gangId, true)
  end
end

return TerritoryObjectBase

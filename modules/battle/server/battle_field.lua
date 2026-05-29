local BattleField = Lib.class("BattleField")
local LoginWaitTime = 10

function BattleField:ctor(battleFieldManager, param)
  self.battleFieldManager = battleFieldManager
  self.uid = param.uid
  self.waitTime = param.waitTime
  self.battleTime = param.battleTime
  self.param = param
  self.hitEffectInfo = {}
  self.bulletEffectInfo = {}
  self.missileInfo = {}
  self.unitList = {}
  self.playerUserIdList = {}
  self.isStart = true
  self.rankData = {}
  self.dropItemId = 100000
  self:lightDropItemTimer()
  self.bulletEffectTimer = World.LightTimer("bulletEffectTimer", 2, function()
    self:broadcastBulletEffect()
    self:broadcastMissile()
    return true
  end)
end

function BattleField:getUid()
  return self.uid
end

function BattleField:quiteBattleField()
  for _, userId in pairs(self.playerUserIdList) do
    local player = Game.GetPlayerByUserId(userId)
    if player then
      player:setMapPos(player.battleLastMapName, player.battleLastPos)
    end
  end
end

function BattleField:onBattleResult()
end

function BattleField:getPlayerList()
  local playerList = {}
  for _, userId in pairs(self.playerUserIdList) do
    local player = Game.GetPlayerByUserId(userId)
    if player then
      table.insert(playerList, player)
    end
  end
  return playerList
end

function BattleField:checkBattleEnd()
  local result = #self.playerUserIdList <= 1
  return result
end

function BattleField:getUnitList(excludeUnit)
  local result = {}
  for _, unit in pairs(self.unitList or {}) do
    if unit ~= excludeUnit then
      table.insert(result, unit)
    end
  end
  return result
end

function BattleField:enter(player)
  table.insert(self.playerUserIdList, player.platformUserId)
  self:onBattleBegin(player)
end

function BattleField:getMathData()
  local mathData = {}
  mathData.totalCount = #self.playerUserIdList
  mathData.totalTime = self.battleTime
  mathData.waitTime = self.waitTime
  mathData.playerUserIdList = self.playerUserIdList
  return mathData
end

function BattleField:enterBattle(player)
  player.battleField = self
  player.battleLastMapName = player.map.name
  player.battleLastPos = player:getPosition()
  player:revive()
  World.LightTimer("vf_app_activity", 200, function()
    if player and player:isValid() then
      Plugins.CallTargetPluginFunc("vf_app_activity", "addGameBadge", player)
    end
  end)
end

function BattleField:getBirthPos(player)
  local bastion = player:getBastion()
  if bastion then
    local rebornPosition, rotation = bastion:getWorldPosition()
    if rebornPosition then
      return rebornPosition, rotation
    end
  end
  local posArray = World.cfg.match.beginPos
  local len = #posArray
  local index = math.random(1, len)
  return posArray[index]
end

function BattleField:onBattleBegin(player)
  local loginTime = os.time()
  player.login_time_ = loginTime
  self:enterBattle(player)
  player:evt_recordPlayerActive(loginTime)
  World.Timer(1, function()
    player:evt_reportEvent("player_in", {})
  end)
  player:checkGuideLockDoor()
end

function BattleField:tryPlayerLeaveBattle(player, runaway, winUserIds)
  print("BattleField:tryPlayerLeaveBattle", player)
  Lib.emitEvent(Event.EVENT_PLAYER_LEAVE_BATTLE, player.platformUserId, runaway, winUserIds)
  player:setInBattle(false)
  if not player.noLeaveBattleMap then
    local map = World.CurWorld:getMap(player.battleLastMapName)
    player:sendPacket({
      pid = "leaveBattleField",
      map = player.battleLastMapName,
      mapId = map and map.id,
      pos = player.battleLastPos,
      runaway = runaway
    })
    player.levelId = 0
    player.controlUnitList = {}
    player.battleField = nil
    player.battleLastMapName = nil
    player.battleLastPos = nil
    player.battleLastRotationYaw = nil
    player.battleLastRotationPitch = nil
  end
  self:removePlayer(player.platformUserId)
end

function BattleField:removePlayer(userId)
  self:removeUnitByUserId(userId)
  Lib.tableRemove(self.playerUserIdList, userId)
  if self:isPlayerEmpty() then
    self:onDestroy()
  end
end

function BattleField:onDestroy()
  self.battleFieldManager:remove(self.uid)
end

function BattleField:update(dt)
  if self.isStart then
    self.battleTime = self.battleTime - dt
    if self.battleTime <= 0 then
    else
    end
  end
end

function BattleField:broadcastAllPacket(packet)
  local curTime = os.time()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() and player.isPlayer and player.login_time_ and curTime - player.login_time_ > LoginWaitTime then
      player:sendPacket(packet)
    end
  end
end

function BattleField:onRevive(player)
  if not player or not player:isValid() then
    return
  end
  local pos, rotation = self:getBirthPos(player)
  player:setMapPos("map001", pos, rotation.y)
  player:sendPacketToTracking({
    pid = "onEntityRevive",
    objID = player.objID
  }, true)
end

local ItemServer = T(Lib, "ItemServer")

function BattleField:createDrop(pos, id, count, itemData, lifeTime, dropState)
  lifeTime = lifeTime or World.cfg.battleDropCD * 20
  local fullName = "myplugin/" .. id
  local item = Item.CreateItem(fullName, 1)
  local createItemParam = {
    map = World.CurMap,
    pos = pos,
    item = item,
    lifeTime = 999999,
    pitch = nil,
    yaw = nil,
    moveTime = 10,
    guardTime = 999999
  }
  local dropItem = DropItemServer.Create(createItemParam)
  itemData = itemData or ItemServer:export_createInventoryItem(id)
  itemData.count = count
  itemData.dropState = dropState
  dropItem:setItemData(itemData)
  dropItem:setConfigPos(pos)
  dropItem:setItemCount(count)
  dropItem:setLifeTime(lifeTime)
  return dropItem
end

function BattleField:testDrops(diePos)
  local itemDataList = {}
  local itemData = ItemServer:export_createInventoryItem(101003)
  table.insert(itemDataList, itemData)
  itemData = ItemServer:export_createInventoryItem(102002)
  table.insert(itemDataList, itemData)
  itemData = ItemServer:export_createInventoryItem(102003)
  table.insert(itemDataList, itemData)
  self:onAddDrops(itemDataList, diePos, 0)
end

function BattleField:lightDropItemTimer()
  self.createCountMap = {}
  local time = World.cfg.battleDropCD * 20
  if not self.dropTimer then
    local tickTime = 0
    self.dropTimer = World.LightTimer("drop behavior", 1, function()
      tickTime = tickTime + 0.05
      for i, v in ipairs(World.cfg.battleDrop) do
        local id = v.id
        local cd = v.cd or 10
        self.createCountMap[i] = self.createCountMap[i] or 1
        if tickTime >= self.createCountMap[i] * cd then
          local pos = Lib.v3(v.pos[1], v.pos[2], v.pos[3])
          local dropItem = self:createDrop(pos, id, v.pickCount, nil, cd * 20, Define.ItemDataDropState.SystemDrop)
          self.createCountMap[i] = self.createCountMap[i] + 1
        end
      end
      return true
    end)
  end
  self:createWeapon()
end

function BattleField:onPickDrop(objID)
end

function BattleField:onAddDrops(itemDataList, diePos, goldCount)
  local posArray = {
    Lib.v3(diePos.x + 1, diePos.y, diePos.z),
    Lib.v3(diePos.x, diePos.y, diePos.z + 1),
    Lib.v3(diePos.x - 1, diePos.y, diePos.z),
    Lib.v3(diePos.x, diePos.y, diePos.z - 1)
  }
  if goldCount and 0 < goldCount then
    local itemData = ItemServer:export_createInventoryItem(Define.GoldItemID, goldCount)
    itemData.dropState = Define.ItemDataDropState.DieDrop
    table.insert(itemDataList, itemData)
  end
  local index = 0
  for _, itemData in pairs(itemDataList) do
    index = index + 1
    local pos = posArray[index]
    pos.y = pos.y + 1
    local id = itemData.itemID
    local dropItem = self:createDrop(pos, id, itemData.count, itemData, nil, Define.ItemDataDropState.DieDrop)
  end
end

function BattleField:createWeapon()
  self.dropData = {}
  for i, v in ipairs(World.cfg.battleDrop) do
    local pos = Lib.v3(v.pos[1], v.pos[2], v.pos[3])
    local id = v.id
    local dropItem = self:createDrop(pos, id, v.pickCount, nil, (v.cd or 10) * 20, Define.ItemDataDropState.SystemDrop)
  end
end

function BattleField:addBulletEffect(hitEffectData, bulletEffectData)
  if hitEffectData then
    table.insert(self.hitEffectInfo, hitEffectData)
  end
  if bulletEffectData then
    table.insert(self.bulletEffectInfo, bulletEffectData)
  end
end

function BattleField:broadcastBulletEffect()
  if #self.hitEffectInfo == 0 and #self.bulletEffectInfo == 0 then
    return
  end
  self:broadcastAllPacket({
    pid = "onBulletEffect",
    hitEffectInfo = self.hitEffectInfo,
    bulletEffectInfo = self.bulletEffectInfo
  })
  self.hitEffectInfo = {}
  self.bulletEffectInfo = {}
end

function BattleField:addMissileInfo(missileData)
  if missileData then
    table.insert(self.missileInfo, missileData)
  end
end

function BattleField:broadcastMissile()
  if #self.missileInfo == 0 then
    return
  end
  self:broadcastAllPacket({
    pid = "onMissileInfo",
    missileInfo = self.missileInfo
  })
  self.missileInfo = {}
end

return BattleField

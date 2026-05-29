local HelperCommonServer = T(Lib, "HelperCommonServer")
local DoorsConfig = T(Config, "DoorsConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_defense_property_copy = {
  false,
  false,
  true,
  true,
  {},
  false
}
ValueDef.bastion_defense_property_runtime = {
  false,
  false,
  true,
  true,
  {},
  false
}
local EntityBastion = Entity

function EntityBastion:getBastionDefenseOwner()
  local ownerId = self:getBastionOwnerId()
  if not ownerId then
    return nil
  end
  local player = Game.GetPlayerByUserId(ownerId)
  if not player then
    return nil
  end
  return player
end

function EntityBastion:getBastionDefenseProperty()
  local ownerId = self:getBastionOwnerId()
  if not ownerId then
    return {}
  end
  local player = Game.GetPlayerByUserId(ownerId)
  if not player then
    return {}
  end
  if not player:isValid() then
    return {}
  end
  local defenseType = self:getBastionDefenseType()
  if defenseType == Define.Bastion.Defense.Type.None then
    return {}
  end
  local item = player:getBastionDefenseItem(defenseType)
  if not item then
    return {}
  end
  return item.propertyDict or {}
end

function EntityBastion:setBastionDefenseProperty(property)
  local ownerId = self:getBastionOwnerId()
  if not ownerId then
    return
  end
  local player = Game.GetPlayerByUserId(ownerId)
  if not player or not player:isValid() then
    return
  end
  local defenseType = self:getBastionDefenseType()
  if defenseType == Define.Bastion.Defense.Type.None then
    return
  end
  local item = player:getBastionDefenseItem(defenseType)
  if not item then
    return
  end
  item.propertyDict = property
  player:setBastionDefenseItem(defenseType, item)
  self:brp_reloadDefensePropertyCopy()
end

function EntityBastion:brp_getDefensePropertyCopy()
  return self:getValue("bastion_defense_property_copy") or {}
end

function EntityBastion:brp_setDefensePropertyCopy(property)
  self:setValue("bastion_defense_property_copy", property)
end

function EntityBastion:brp_reloadDefensePropertyCopy()
  local currentProperty = self:getBastionDefenseProperty()
  local cfg = self:cfg() or {}
  local defenseStatusConfig = cfg.defenseStatusConfig or {}
  local status = currentProperty.status or Define.Bastion.Defense.Status.None
  if status ~= Define.Bastion.Defense.Status.None then
    local config = defenseStatusConfig[status] or {}
    local actorName = config.actorName or cfg.actorName
    local collisionGroup = config.collisionGroup or 0
    self:setCollisionGroup(collisionGroup)
    self:changeActor(actorName)
  end
  self:brp_setDefensePropertyCopy(Lib.copy(currentProperty))
end

function EntityBastion:bdp_getConfigID()
  local property = self:getBastionDefenseProperty()
  return property.id or 0
end

function EntityBastion:bdp_getConfig()
  local configID = self:bdp_getConfigID()
  return DoorsConfig:getCfgById(configID)
end

function EntityBastion:bdp_getMaxHp()
  local config = self:bdp_getConfig()
  if not config then
    return 0
  end
  return config.maxHp
end

function EntityBastion:bdp_getDefense()
  local config = self:bdp_getConfig()
  if not config then
    return 0
  end
  return config.defense
end

function EntityBastion:bdp_getDefenseLevel()
  local config = self:bdp_getConfig()
  if not config then
    return 0
  end
  return config.defenseLevel
end

function EntityBastion:bdp_getHackTime()
  local config = self:bdp_getConfig()
  if not config then
    return 60
  end
  return config.hackTime
end

function EntityBastion:bdp_getRecoverInterval(status)
  local config = self:bdp_getConfig()
  if not config then
    return 60
  end
  if status == Define.Bastion.Defense.Status.Damaged then
    return config.damagedRecoverTime
  elseif status == Define.Bastion.Defense.Status.Hacked then
    return config.hackedRecoverTime
  end
  return 60
end

function EntityBastion:bdp_getHp()
  local property = self:getBastionDefenseProperty()
  return property.hp or 0
end

function EntityBastion:bdp_getStatus()
  local property = self:getBastionDefenseProperty()
  return property.status or Define.Bastion.Defense.Status.None
end

function EntityBastion:bdp_getStatusTimeStatus()
  local property = self:getBastionDefenseProperty()
  return property.statusTimeStamp or 0
end

function EntityBastion:bdp_setHp(hp)
  local property = self:getBastionDefenseProperty()
  local maxHp = self:bdp_getMaxHp()
  property.hp = math.max(0, math.min(maxHp, hp))
  self:setBastionDefenseProperty(property)
end

function EntityBastion:bdp_setStatus(status)
  local property = self:getBastionDefenseProperty()
  property.status = status
  property.statusTimeStamp = os.time()
  self:setBastionDefenseProperty(property)
  if status == Define.Bastion.Defense.Status.Hacked then
    self:brp_clearHackInfoDict()
  elseif status == Define.Bastion.Defense.Status.Damaged then
    self:brp_clearHackInfoDict()
    local config = World.cfg.bastionSetting or {}
    local defense = config.defense or {}
    local exploredEffect = defense.exploredEffect or {}
    local packet = {
      pid = "S2C_PlayBastionEffect",
      effectName = exploredEffect.effectName or "",
      position = self:getPosition(),
      timeScale = exploredEffect.timeScale or 1,
      bodyScale = exploredEffect.bodyScale or Vector3.new(1, 1, 1),
      yaw = exploredEffect.yaw or 0,
      duration = exploredEffect.duration or 10000
    }
    WorldServer.BroadcastPacket(packet)
    local config = self:bdp_getConfig()
    if config then
      HelperCommonServer:export_play3DSoundByKey(config.damagedSound, self:getPosition())
    end
  elseif status == Define.Bastion.Defense.Status.Normal then
    self:brp_clearAttackerInfo()
  end
end

function EntityBastion:bdp_increaseHp(hp)
  local currentHp = self:bdp_getHp()
  local newHp = currentHp + hp
  self:bdp_setHp(newHp)
end

function EntityBastion:bdp_decreaseHp(hp)
  local currentHp = self:bdp_getHp()
  local newHp = currentHp - hp
  self:bdp_setHp(newHp)
end

function EntityBastion:bdp_takeDamage(damage, attackerObjID)
  local status = self:bdp_getStatus()
  if status == Define.Bastion.Defense.Status.Damaged then
    return 0
  end
  local oldHp = self:bdp_getHp()
  self:bdp_decreaseHp(damage)
  local currentTime = os.time()
  local oldInfo = self:brp_getAttackerInfo(attackerObjID) or {attackTime = 0}
  local config = World.cfg.bastionSetting or {}
  local defense = config.defense or {}
  local attackedTipInterval = defense.attackedTipInterval or 10
  if currentTime > oldInfo.attackTime + attackedTipInterval then
    local owner = self:getBastionDefenseOwner()
    if owner and owner:isValid() and owner.isPlayer then
      local hurtEntity = World.CurWorld:getEntity(attackerObjID)
      if hurtEntity and hurtEntity:isValid() and hurtEntity.isPlayer then
        local param = {}
        param.attackerName = hurtEntity.name
        param.type = Define.Bastion.Defense.Tips.Type.AttackDoor
        owner:S2C_ShowBastionDefenseTips(param)
      end
    end
    self:brp_addAttackerInfo(attackerObjID, {attackTime = currentTime})
  end
  local newHp = self:bdp_getHp()
  local config = self:bdp_getConfig()
  if config then
    HelperCommonServer:export_play3DSoundByKey(config.hurtSound, self:getPosition())
  end
  if 0 < oldHp and newHp <= 0 then
    self:bdp_setStatus(Define.Bastion.Defense.Status.Damaged)
  end
  local headUIData = {
    progress = {
      visible = 0 < newHp,
      min = newHp,
      max = self:bdp_getMaxHp(),
      hideTime = os.time() + 5
    }
  }
  self:setHeadUIData(headUIData)
  return damage
end

function EntityBastion:bdp_confirmHack(hackerID)
  local status = self:bdp_getStatus()
  if status == Define.Bastion.Defense.Status.Damaged then
    return
  end
  local hackerDict = self:brp_getHackInfoDict()
  local config = self:bdp_getConfig()
  for id, hackInfo in pairs(hackerDict) do
    local player = Game.GetPlayerByUserId(hackInfo.operatorId)
    if player and player:isValid() and player.isPlayer then
      if config then
        player:S2C_play2DSoundByKey(config.succeedHackSound)
      end
      local param = {}
      param.attackerName = player.name
      param.type = Define.Bastion.Defense.Tips.Type.HackedSucceed
      player:S2C_ShowBastionDefenseTips(param)
      player:bst_ReportHackDoor(Define.EventTracking.Defense.Door.Hack.Succeed, self:getBastionOwnerId())
    end
  end
  local player = Game.GetPlayerByUserId(hackerID)
  if player and player:isValid() and player.isPlayer then
    local param = {}
    param.attackerName = player.name
    param.type = Define.Bastion.Defense.Tips.Type.Hacked
    local owner = self:getBastionDefenseOwner()
    if owner and owner:isValid() and owner.isPlayer then
      owner:S2C_ShowBastionDefenseTips(param)
    end
  end
  self:bdp_setStatus(Define.Bastion.Defense.Status.Hacked)
  self:brp_addHoldDoorCount(1)
end

function EntityBastion:bdp_cancelHack(hackerID)
  local status = self:bdp_getStatus()
  if status == Define.Bastion.Defense.Status.Damaged then
    return
  end
  local config = self:bdp_getConfig()
  if config then
    local player = Game.GetPlayerByUserId(hackerID)
    if player and player:isValid() and player.isPlayer then
      player:S2C_play2DSoundByKey(config.failedHackSound)
      local param = {}
      param.type = Define.Bastion.Defense.Tips.Type.HackedFailed
      player:S2C_ShowBastionDefenseTips(param)
      player:bst_ReportHackDoor(Define.EventTracking.Defense.Door.Hack.Failed, self:getBastionOwnerId())
    end
  end
  self:brp_removeHacker(hackerID)
end

function EntityBastion:bdp_update(timeDelta)
  local status = self:bdp_getStatus()
  if status == Define.Bastion.Defense.Status.Damaged then
    local recoverInterval = self:bdp_getRecoverInterval(status)
    local currentTime = os.time()
    local statusTimeStamp = self:bdp_getStatusTimeStatus()
    if currentTime >= statusTimeStamp + recoverInterval then
      self:bdp_setHp(self:bdp_getMaxHp())
      self:bdp_setStatus(Define.Bastion.Defense.Status.Normal)
    end
  elseif status == Define.Bastion.Defense.Status.Hacked then
    local recoverInterval = self:bdp_getRecoverInterval(status)
    local currentTime = os.time()
    local statusTimeStamp = self:bdp_getStatusTimeStatus()
    if currentTime >= statusTimeStamp + recoverInterval then
      self:bdp_setStatus(Define.Bastion.Defense.Status.Normal)
      self:brp_setHoldDoorCount(0)
    end
  elseif status == Define.Bastion.Defense.Status.Normal then
    local now = os.time()
    local hackInfoDict = self:brp_getHackInfoDict()
    local hackedIds = {}
    for playerId, hackInfo in pairs(hackInfoDict) do
      if now >= hackInfo.endTime then
        table.insert(hackedIds, hackInfo.operatorId)
      end
    end
    for index, id in pairs(hackedIds) do
      self:bdp_cancelHack(id)
    end
  end
end

function EntityBastion:bdp_onPlayerDie(playerId)
  local status = self:bdp_getStatus()
  if status == Define.Bastion.Defense.Status.Normal then
    if self:brp_getHackerInfo(playerId) then
      local player = Game.GetPlayerByUserId(playerId)
      if player and player:isValid() and player.isPlayer then
        player:bst_ReportHackDoor(Define.EventTracking.Defense.Door.Hack.Killed, self:getBastionOwnerId())
      end
    end
    self:brp_removeHacker(playerId)
  end
end

function EntityBastion:brp_getDefensePropertyRunTime()
  return self:getValue("bastion_defense_property_runtime") or {}
end

function EntityBastion:brp_setDefensePropertyRunTime(property)
  self:setValue("bastion_defense_property_runtime", property)
end

function EntityBastion:brp_getInitRotation()
  local property = self:brp_getDefensePropertyRunTime()
  return property.initRotation or Vector3.new(0, 0, 0)
end

function EntityBastion:brp_setInitRotation(rotation)
  local property = self:brp_getDefensePropertyRunTime()
  property.initRotation = rotation
  self:brp_setDefensePropertyRunTime(property)
end

function EntityBastion:brp_getHoldDoorCount()
  local property = self:brp_getDefensePropertyRunTime()
  return property.holdDoorCount or 0
end

function EntityBastion:brp_setHoldDoorCount(count)
  local property = self:brp_getDefensePropertyRunTime()
  property.holdDoorCount = math.max(0, count)
  self:brp_setDefensePropertyRunTime(property)
  if property.holdDoorCount > 0 then
    local initRotation = self:brp_getInitRotation()
    local newRotation = Lib.copy(initRotation)
    newRotation.y = newRotation.y + 90
    self:setRotation(newRotation.y, newRotation.x, newRotation.z)
    self:syncPosDelay(1)
  else
    local initRotation = self:brp_getInitRotation()
    self:setRotation(initRotation.y, initRotation.x, initRotation.z)
    self:syncPosDelay(1)
  end
end

function EntityBastion:brp_addHoldDoorCount(count)
  local currentCount = self:brp_getHoldDoorCount()
  self:brp_setHoldDoorCount(currentCount + count)
end

function EntityBastion:brp_delHoldDoorCount(count)
  local currentCount = self:brp_getHoldDoorCount()
  self:brp_setHoldDoorCount(currentCount - count)
end

function EntityBastion:brp_getHackInfoDict()
  local property = self:brp_getDefensePropertyRunTime()
  return property.hackDict or {}
end

function EntityBastion:brp_setHackInfoDict(dict)
  local property = self:brp_getDefensePropertyRunTime()
  property.hackDict = dict
  self:brp_setDefensePropertyRunTime(property)
end

function EntityBastion:brp_clearHackInfoDict(dict)
  local hackDict = self:brp_getHackInfoDict()
  local ids = {}
  for id, v in pairs(hackDict) do
    table.insert(ids, id)
  end
  for i, id in pairs(ids) do
    self:brp_removeHacker(id)
  end
end

function EntityBastion:brp_getHackerInfo(operatorId)
  local hackDict = self:brp_getHackInfoDict()
  return hackDict[operatorId]
end

function EntityBastion:brp_addHacker(operatorId)
  local hackTime = self:bdp_getHackTime()
  local info = {}
  info.operatorId = operatorId
  info.startTime = os.time()
  info.endTime = info.startTime + hackTime
  local hackDict = self:brp_getHackInfoDict()
  hackDict[operatorId] = info
  self:brp_setHackInfoDict(hackDict)
  local operator = Game.GetPlayerByUserId(operatorId)
  if operator and operator:isValid() and operator.isPlayer then
    local param = {}
    param.attackerName = operator.name
    param.type = Define.Bastion.Defense.Tips.Type.StartHacked
    local owner = self:getBastionDefenseOwner()
    if owner and owner:isValid() and owner.isPlayer then
      owner:S2C_ShowBastionDefenseTips(param)
    end
    operator:bhp_setHackObjID(self.objID)
    operator:bst_ReportHackDoor(Define.EventTracking.Defense.Door.Hack.Start, self:getBastionOwnerId())
  end
end

function EntityBastion:brp_removeHacker(operatorId)
  local operator = Game.GetPlayerByUserId(operatorId)
  if operator then
    operator:bhp_setHackObjID(0)
  end
  local hackDict = self:brp_getHackInfoDict()
  hackDict[operatorId] = nil
  self:brp_setHackInfoDict(hackDict)
end

function EntityBastion:brp_getAttackerDict()
  local property = self:brp_getDefensePropertyRunTime()
  return property.attackerDict or {}
end

function EntityBastion:brp_setAttackerDict(dict)
  local property = self:brp_getDefensePropertyRunTime()
  property.attackerDict = dict
  self:brp_setDefensePropertyRunTime(property)
end

function EntityBastion:brp_getAttackerInfo(id)
  local dict = self:brp_getAttackerDict()
  return dict[id]
end

function EntityBastion:brp_addAttackerInfo(id, info)
  local dict = self:brp_getAttackerDict()
  dict[id] = info
  self:brp_setAttackerDict(dict)
end

function EntityBastion:brp_removeAttackerInfo(id)
  local dict = self:brp_getAttackerDict()
  dict[id] = nil
  self:brp_setAttackerDict(dict)
end

function EntityBastion:brp_clearAttackerInfo()
  self:brp_setAttackerDict({})
end

function EntityBastion:recordHurtData(id, hurtValue, playerID)
  self.reportDataPlayerIDS = self.reportDataPlayerIDS or {}
  if not Lib.tableContain(self.reportDataPlayerIDS, playerID) then
    table.insert(self.reportDataPlayerIDS, playerID)
  end
  self.reportDataHurtValues = self.reportDataHurtValues or {}
  self.reportDataHurtValues[id] = self.reportDataHurtValues[id] and self.reportDataHurtValues[id] + hurtValue or hurtValue
end

function EntityBastion:clearRecordHurtData()
  self.reportDataPlayerIDS = {}
  self.reportDataHurtValues = {}
end

function EntityBastion:getRecordHurtData()
  local playerIDStr = ""
  for i, v in ipairs(self.reportDataPlayerIDS) do
    if playerIDStr ~= "" then
      playerIDStr = playerIDStr .. ","
    end
    playerIDStr = playerIDStr .. v
  end
  local hurtDataStr = ""
  for id, v in pairs(self.reportDataHurtValues) do
    if hurtDataStr ~= "" then
      hurtDataStr = hurtDataStr .. ";"
    end
    hurtDataStr = hurtDataStr .. id .. "," .. v
  end
  return playerIDStr, hurtDataStr
end

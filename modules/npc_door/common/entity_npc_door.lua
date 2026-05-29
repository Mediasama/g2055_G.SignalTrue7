local HelperCommonServer = T(Lib, "HelperCommonServer")
local DoorsConfig = T(Config, "DoorsConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.npc_door_property = {
  false,
  false,
  true,
  true,
  {},
  false
}
local EntityNPCDoor = Entity

function EntityNPCDoor:ndp_getProperty()
  return self:getValue("npc_door_property") or {}
end

function EntityNPCDoor:ndp_setProperty(property)
  self:setValue("npc_door_property", property)
end

function EntityNPCDoor:ndp_getID()
  local property = self:ndp_getProperty() or {}
  return property.uid
end

function EntityNPCDoor:ndp_setID(uid)
  local property = self:ndp_getProperty() or {}
  property.uid = uid
  self:ndp_setProperty(property)
end

function EntityNPCDoor:ndp_getConfigID()
  local property = self:ndp_getProperty()
  return property.configID or 0
end

function EntityNPCDoor:ndp_setConfigID(id)
  local property = self:ndp_getProperty()
  property.configID = id
  self:ndp_setProperty(property)
end

function EntityNPCDoor:ndp_getConfig()
  local configID = self:ndp_getConfigID()
  return DoorsConfig:getCfgById(configID)
end

function EntityNPCDoor:ndp_getMaxHp()
  local config = self:ndp_getConfig()
  if not config then
    return 0
  end
  return config.maxHp
end

function EntityNPCDoor:ndp_getDefense()
  local config = self:ndp_getConfig()
  if not config then
    return 0
  end
  return config.defense
end

function EntityNPCDoor:ndp_getDefenseLevel()
  local config = self:ndp_getConfig()
  if not config then
    return 0
  end
  return config.defenseLevel
end

function EntityNPCDoor:ndp_getHackTime()
  local config = self:ndp_getConfig()
  if not config then
    return 60
  end
  return config.hackTime
end

function EntityNPCDoor:ndp_getRecoverInterval(status)
  local config = self:ndp_getConfig()
  if not config then
    return 60
  end
  if status == Define.NPCDoor.Status.Damaged then
    return config.damagedRecoverTime
  elseif status == Define.NPCDoor.Status.Hacked then
    return config.hackedRecoverTime
  end
  return 60
end

function EntityNPCDoor:ndp_getHp()
  local property = self:ndp_getProperty()
  return property.hp or 0
end

function EntityNPCDoor:ndp_setHp(hp)
  local property = self:ndp_getProperty()
  local maxHp = self:ndp_getMaxHp()
  property.hp = math.max(0, math.min(maxHp, hp))
  self:ndp_setProperty(property)
end

function EntityNPCDoor:ndp_getStatus()
  local property = self:ndp_getProperty()
  return property.status or Define.NPCDoor.Status.None
end

function EntityNPCDoor:ndp_getStatusTimeStatus()
  local property = self:ndp_getProperty()
  return property.statusTimeStamp or 0
end

function EntityNPCDoor:ndp_setStatus(status)
  local property = self:ndp_getProperty()
  property.status = status
  property.statusTimeStamp = os.time()
  self:ndp_setProperty(property)
  if status == Define.NPCDoor.Status.Hacked then
    local hackerDict = self:ndp_getHackInfoDict()
    local config = self:ndp_getConfig()
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
      end
    end
    self:ndp_clearHackInfoDict()
  elseif status == Define.NPCDoor.Status.Damaged then
    self:ndp_clearHackInfoDict()
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
  elseif status == Define.NPCDoor.Status.Normal then
  end
  local cfg = self:cfg() or {}
  local defenseStatusConfig = cfg.defenseStatusConfig or {}
  local config = defenseStatusConfig[status] or {}
  local actorName = config.actorName or cfg.actorName
  local collisionGroup = config.collisionGroup or 0
  self:setCollisionGroup(collisionGroup)
  self:changeActor(actorName)
end

function EntityNPCDoor:ndp_getInitRotation()
  local property = self:ndp_getProperty()
  return property.initRotation or Vector3.new(0, 0, 0)
end

function EntityNPCDoor:ndp_setInitRotation(rotation)
  local property = self:ndp_getProperty()
  property.initRotation = rotation
  self:ndp_setProperty(property)
end

function EntityNPCDoor:ndp_getHoldDoorCount()
  local property = self:ndp_getProperty()
  return property.holdDoorCount or 0
end

function EntityNPCDoor:ndp_setHoldDoorCount(count)
  local property = self:ndp_getProperty()
  property.holdDoorCount = math.max(0, count)
  self:ndp_setProperty(property)
  if property.holdDoorCount > 0 then
    local initRotation = self:ndp_getInitRotation()
    local newRotation = Lib.copy(initRotation)
    newRotation.y = newRotation.y + 90
    self:setRotation(newRotation.y, newRotation.x, newRotation.z)
    self:syncPosDelay(1)
  else
    local initRotation = self:ndp_getInitRotation()
    self:setRotation(initRotation.y, initRotation.x, initRotation.z)
    self:syncPosDelay(1)
  end
end

function EntityNPCDoor:ndp_addHoldDoorCount(count)
  local currentCount = self:ndp_getHoldDoorCount()
  self:ndp_setHoldDoorCount(currentCount + count)
end

function EntityNPCDoor:ndp_delHoldDoorCount(count)
  local currentCount = self:ndp_getHoldDoorCount()
  self:ndp_setHoldDoorCount(currentCount - count)
end

function EntityNPCDoor:ndp_getHackInfoDict()
  local property = self:ndp_getProperty()
  return property.hackDict or {}
end

function EntityNPCDoor:ndp_setHackInfoDict(dict)
  local property = self:ndp_getProperty()
  property.hackDict = dict
  self:ndp_setProperty(property)
end

function EntityNPCDoor:ndp_clearHackInfoDict(dict)
  local hackDict = self:ndp_getHackInfoDict()
  local ids = {}
  for id, v in pairs(hackDict) do
    table.insert(ids, id)
  end
  for i, id in pairs(ids) do
    self:ndp_removeHacker(id)
  end
end

function EntityNPCDoor:ndp_getHackerInfo(operatorId)
  local hackDict = self:ndp_getHackInfoDict()
  return hackDict[operatorId]
end

function EntityNPCDoor:ndp_addHacker(operatorId)
  local hackTime = self:ndp_getHackTime()
  local info = {}
  info.operatorId = operatorId
  info.startTime = os.time()
  info.endTime = info.startTime + hackTime
  local hackDict = self:ndp_getHackInfoDict()
  hackDict[operatorId] = info
  self:ndp_setHackInfoDict(hackDict)
  local operator = Game.GetPlayerByUserId(operatorId)
  if operator and operator:isValid() and operator.isPlayer then
    operator:bhp_setHackObjID(self.objID)
  end
end

function EntityNPCDoor:ndp_removeHacker(operatorId)
  local operator = Game.GetPlayerByUserId(operatorId)
  if operator then
    operator:bhp_setHackObjID(0)
  end
  local hackDict = self:ndp_getHackInfoDict()
  hackDict[operatorId] = nil
  self:ndp_setHackInfoDict(hackDict)
end

function EntityNPCDoor:ndp_increaseHp(hp)
  local currentHp = self:ndp_getHp()
  local newHp = currentHp + hp
  self:ndp_setHp(newHp)
end

function EntityNPCDoor:ndp_decreaseHp(hp)
  local currentHp = self:ndp_getHp()
  local newHp = currentHp - hp
  self:ndp_setHp(newHp)
end

function EntityNPCDoor:ndp_takeDamage(damage, attackerObjID)
  local status = self:ndp_getStatus()
  if status == Define.NPCDoor.Status.Damaged then
    return 0
  end
  local oldHp = self:ndp_getHp()
  self:ndp_decreaseHp(damage)
  local newHp = self:ndp_getHp()
  local config = self:ndp_getConfig()
  if config then
    HelperCommonServer:export_play3DSoundByKey(config.hurtSound, self:getPosition())
  end
  if 0 < oldHp and newHp <= 0 then
    self:ndp_setStatus(Define.NPCDoor.Status.Damaged)
  end
  local headUIData = {
    progress = {
      visible = 0 < newHp,
      min = newHp,
      max = self:ndp_getMaxHp(),
      hideTime = os.time() + 5
    }
  }
  self:setHeadUIData(headUIData)
  return damage
end

function EntityNPCDoor:ndp_confirmHack(hackerID)
  local status = self:ndp_getStatus()
  if status == Define.NPCDoor.Status.Damaged then
    return
  end
  self:ndp_setStatus(Define.NPCDoor.Status.Hacked)
  self:ndp_addHoldDoorCount(1)
end

function EntityNPCDoor:ndp_cancelHack(hackerID)
  local status = self:ndp_getStatus()
  if status == Define.NPCDoor.Status.Damaged then
    return
  end
  local config = self:ndp_getConfig()
  if config then
    local player = Game.GetPlayerByUserId(hackerID)
    if player and player:isValid() and player.isPlayer then
      player:S2C_play2DSoundByKey(config.failedHackSound)
      local param = {}
      param.type = Define.Bastion.Defense.Tips.Type.HackedFailed
      player:S2C_ShowBastionDefenseTips(param)
    end
  end
  self:ndp_removeHacker(hackerID)
end

function EntityNPCDoor:ndp_update(timeDelta)
  local status = self:ndp_getStatus()
  if status == Define.NPCDoor.Status.Damaged then
    local recoverInterval = self:ndp_getRecoverInterval(status)
    local currentTime = os.time()
    local statusTimeStamp = self:ndp_getStatusTimeStatus()
    if currentTime >= statusTimeStamp + recoverInterval then
      self:ndp_setHp(self:ndp_getMaxHp())
      self:ndp_setStatus(Define.NPCDoor.Status.Normal)
    end
  elseif status == Define.NPCDoor.Status.Hacked then
    local recoverInterval = self:ndp_getRecoverInterval(status)
    local currentTime = os.time()
    local statusTimeStamp = self:ndp_getStatusTimeStatus()
    if currentTime >= statusTimeStamp + recoverInterval then
      self:ndp_setStatus(Define.NPCDoor.Status.Normal)
      self:ndp_setHoldDoorCount(0)
    end
  elseif status == Define.NPCDoor.Status.Normal then
    local now = os.time()
    local hackInfoDict = self:ndp_getHackInfoDict()
    local hackedIds = {}
    for playerId, hackInfo in pairs(hackInfoDict) do
      if now >= hackInfo.endTime then
        table.insert(hackedIds, hackInfo.operatorId)
      end
    end
    for index, id in pairs(hackedIds) do
      self:ndp_cancelHack(id)
    end
  end
end

function EntityNPCDoor:ndp_onPlayerDie(playerId)
  local status = self:ndp_getStatus()
  if status == Define.NPCDoor.Status.Normal then
    self:ndp_removeHacker(playerId)
  end
end

local Player = _ENV.Player
local Weapon = require("server.weapon")
local WeaponConfig = require("common.config.weapon_config")

function Player:changeWeapon(id)
  self:pam_stopMotion()
  if id == Define.GoldItemID then
    return
  end
  if self.weapon then
    self.weapon:release()
  end
  self.weapon = Weapon.new(self, id)
end

function Player:changeWeapon2C(id)
  self:sendPacket({
    pid = "ChangeWeapon",
    id = id
  })
end

function Player:setDefaultWeapon()
  self.weaponData = {}
  local mainWeaponID = tonumber(World.cfg.defaultWeaponID)
  local conf1 = WeaponConfig:getCfgById(mainWeaponID)
  local count1 = conf1.bulletCount
  table.insert(self.weaponData, {id = mainWeaponID, bulletCount = count1})
  if World.cfg.subWeaponID then
    local subWeaponID = tonumber(World.cfg.subWeaponID)
    local conf2 = WeaponConfig:getCfgById(subWeaponID)
    local count2 = conf2.bulletCount
    table.insert(self.weaponData, {id = subWeaponID, bulletCount = count2})
  end
  self.handSelectIndex = 0
  self:changeWeapon(mainWeaponID)
  local list = self:getInventory(Define.InventoryType.HandBag)
  for i = 1, 3 do
    local itemData = list[i]
    if itemData and itemData.isMelee then
      local cfg = WeaponConfig:getCfgById(itemData.itemID)
      if itemData.bulletCount <= cfg.bulletCount / 10 then
        self:sendPacket({
          pid = "onMeleeTwinkle",
          index = i,
          guid = itemData.guid
        })
      end
    end
  end
end

function Player:showDropWeapon(weaponID)
  self:sendPacket({
    pid = "ShowDropWeapon",
    weaponID = weaponID
  })
end

function Player:playerSkillAction(actionName)
  EntityServer.playAction({
    entity = self,
    actionName = "idle",
    actionTime = 0,
    includeSelf = true
  })
end

function Player:hitBack(target)
  if not self.weapon then
    return
  end
  local conf = self.skillJsonConf
  if not conf then
    return
  end
  if target.isNearDoor and target.isMoving then
    return
  end
  local dis, time = conf.hurtDistance, conf.hurtTime
  if not dis or dis <= 0 then
    return
  end
  print("in hitBack = ", dis)
  local v = Lib.v3(0, 0, 0)
  if dis ~= 0 then
    v = target:getPosition() - Lib.tov3(self:getPosition())
    v.y = 0
    v:normalize()
    v = v * dis
  end
  local pos = target:getPosition() + v
  target:setForceMove(pos, time)
  self:sendPacketToTracking({
    pid = "syncForceMoveToAll",
    objID = target.objID,
    pos = pos,
    time = time + 3
  }, true)
end

function Player:recordUseBullet(id, num)
  self:recordCurSecondData("bullet_list", 0, id, num)
end

function Player:recordHitBodyNum(objID, id, num)
  self:recordCurSecondData("hitbox_list", objID, id, num)
end

function Player:recordWeaponHitNum(objID, id, num)
  self:recordCurSecondData("arms_hit", objID, id, num)
end

function Player:recordWeaponHitDamage(objID, id, num)
  self:recordCurSecondData("arms_damage", objID, id, num)
end

function Player:recordBodyDamage(objID, id, num)
  self:recordCurSecondData("woundedbox_list", objID, id, num)
end

function Player:recordCurSecondData(key, objID, id, num)
  local tick = World.CurWorld:getTickCount()
  local second = math.ceil(Lib.tickToTime(tick) / 1000)
  self.weaponRecordData = self.weaponRecordData or {}
  for t, data in pairs(self.weaponRecordData) do
    if 30 <= second - t then
      self.weaponRecordData[t] = nil
    end
  end
  local data = self.weaponRecordData[second]
  if not data then
    self.weaponRecordData[second] = {}
    data = self.weaponRecordData[second]
  end
  data[objID] = data[objID] or {}
  data[objID][key] = data[objID][key] or {}
  local list = data[objID][key]
  list[id] = list[id] and list[id] + num or num
end

local function getRecordToString(weaponRecordData, objID, key)
  local costBulletArray = {}
  for _, record in pairs(weaponRecordData or {}) do
    if record[objID] then
      if not record[objID][key] then
        return ""
      end
      for id, num in pairs(record[objID][key]) do
        costBulletArray[id] = costBulletArray[id] and costBulletArray[id] + num or num
      end
    end
  end
  local str = ""
  for id, num in pairs(costBulletArray) do
    if str ~= "" then
      str = str .. ";"
    end
    str = str .. id .. "," .. num
  end
  return str
end

function Player:insertKillCommonData(data, objID)
  self.weapon:saveBulletCount()
  local inventory = self:getInventory(Define.InventoryType.HandBag)
  local str = ""
  for i = 1, World.cfg.inventory.handBag do
    local data = inventory[i]
    if data and data.bulletCount > -1 then
      if str ~= "" then
        str = str .. ";"
      end
      str = str .. data.itemID .. "," .. data.bulletCount
    end
  end
  data.all_bullet_list = str
  data.bullet_list = getRecordToString(self.weaponRecordData, 0, "bullet_list")
  data.hitbox_list = getRecordToString(self.weaponRecordData, objID, "hitbox_list")
  data.arms_hit = getRecordToString(self.weaponRecordData, objID, "arms_hit")
  data.arms_damage = getRecordToString(self.weaponRecordData, objID, "arms_damage")
  data.woundedbox_list = getRecordToString(self.weaponRecordData, objID, "woundedbox_list")
end

function Player:recordDamage(damageInfo, hurtValue)
  if not damageInfo.attackCount then
    return
  end
  self:recordHitBodyNum(damageInfo.hurtObjID, damageInfo.hurtType, damageInfo.attackCount)
  if damageInfo.weaponId then
    self:recordWeaponHitNum(damageInfo.hurtObjID, damageInfo.weaponId, damageInfo.attackCount)
  end
  local hurtToolID = damageInfo.weaponId or damageInfo.vehicleId
  if hurtToolID then
    self:recordWeaponHitDamage(damageInfo.hurtObjID, hurtToolID, hurtValue)
  end
  self:recordBodyDamage(damageInfo.hurtObjID, damageInfo.hurtType, hurtValue)
end

function Player:reportDoorDie(entity, damageType, damage_means)
  local ownerId = entity:getBastionOwnerId()
  local player = Game.GetPlayerByUserId(ownerId)
  local teamId = ""
  if player then
    teamId = player:getGangId()
  end
  local data = {
    target_type = 1,
    target_owner_id = ownerId,
    target_team_id = teamId,
    target_car_id = -1,
    target_door_id = entity:bdp_getConfigID(),
    damage_type = damageType,
    damage_means = damage_means
  }
  self:insertKillCommonData(data, entity.objID)
  self:evt_reportEvent("player_kill", data, true)
end

function Player:reportPlayerDie(entity, damageType, damage_means)
  local ownerId = entity.platformUserId
  local teamId = entity:getGangId()
  local data = {
    target_type = 0,
    target_owner_id = ownerId,
    target_team_id = teamId,
    target_car_id = -1,
    target_door_id = -1,
    damage_type = damageType,
    damage_means = damage_means
  }
  self:insertKillCommonData(data, entity.objID)
  self:evt_reportEvent("player_kill", data, true)
end

function Player:reportCarDie(entity, damageType, damage_means)
  local ownerId = entity:getVehicleOwner()
  local player = Game.GetPlayerByUserId(ownerId)
  if not player or not player:isValid() then
    return
  end
  local teamId = player:getGangId()
  local data = {
    target_type = 2,
    target_owner_id = ownerId,
    target_team_id = teamId,
    target_car_id = nil,
    target_door_id = entity:bdp_getConfigID(),
    damage_type = damageType,
    damage_means = damage_means
  }
  self:insertKillCommonData(data, entity.objID)
  self:evt_reportEvent("player_kill", data, true)
end

function Player:reportDoorBeKill(entity, damageType, damage_means, platformUserId)
  local data = {
    die_type = 1,
    die_way = damageType,
    die_mean = damage_means,
    kill_player_id = platformUserId,
    kill_time = entity:bdp_getStatusTimeStatus()
  }
  data.hurt_player_id_list, data.means_damage = entity:getRecordHurtData()
  self:evt_reportEvent("player_die", data, true)
  entity:clearRecordHurtData()
end

function Player:reportPlayerBeKill(entity, damageType, damage_means, platformUserId)
  local data = {
    die_type = 0,
    die_way = damageType,
    die_mean = damage_means,
    kill_player_id = platformUserId,
    kill_time = entity:getLostHPTime()
  }
  data.hurt_player_id_list, data.means_damage = entity:getRecordHurtData()
  self:evt_reportEvent("player_die", data, true)
end

function Player:reportCarBeKill(entity, damageType, damage_means, platformUserId)
  local data = {
    die_type = 2,
    die_way = damageType,
    die_mean = damage_means,
    kill_player_id = platformUserId,
    kill_time = entity:getLostHPTime()
  }
  data.hurt_player_id_list, data.means_damage = entity:getRecordHurtData()
  self:evt_reportEvent("player_die", data, true)
end

local WeaponServer = T(Lib, "WeaponServer")
local VehicleServer = T(Lib, "VehicleServer")
local VehicleBaseConfig = T(Config, "VehicleBaseConfig")

local function calculateHurtValue(weaponAttack, weaponLevel, defenseLevel, defenseValue)
  local hurtValue = 1
  if defenseLevel <= weaponLevel then
    hurtValue = math.max(weaponAttack - defenseValue, 1)
  end
  return hurtValue
end

function Player:BulletDoDamage(packet)
  local damageInfo = packet.damageInfo
  local entity = World.CurWorld:getEntity(damageInfo.hurtObjID)
  local attackEntity = World.CurWorld:getEntity(damageInfo.attackObjID)
  if entity and entity:isValid() and entity:cfg().canAttack and attackEntity and attackEntity:isValid() then
    if damageInfo.hurtObjID == damageInfo.attackObjID then
      print("\229\174\185\233\148\153\229\164\132\231\144\134\239\188\140\232\135\170\229\183\177\230\137\147\229\136\176\232\135\170\229\183\177")
      return
    end
    if entity:isInvincible() or entity:checkIsState(Define.CHARACTER_STATE_TYPE.BeCARRY) then
      return
    end
    if entity:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) then
      local reportData = {}
      reportData.double_action_type = Define.EventTracking.UseDoubleAction.ActionType.Shame
      reportData.action_time = 0
      self:evt_reportEvent(Define.EventTracking.Type.UseDoubleAction, reportData, true)
    end
    if entity:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) then
      entity:beTeabagAction(attackEntity)
      return
    end
    local distance = Lib.getPosDistance(damageInfo.damagePos, damageInfo.sourcePos)
    local weaponHurtValue, weaponLevel, isMelee
    local isPlayerAtt = damageInfo.weaponId ~= nil
    local curTargetPos = entity:getPosition()
    local curSourcePos = attackEntity:getPosition()
    if not packet.skillJsonConf and (not (not (Lib.getPosDistance(damageInfo.targetPos, curTargetPos) > 2) or entity:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND)) or Lib.getPosDistance(damageInfo.sourcePos, curSourcePos) > 2) then
      Lib.logInfo("\230\156\141\229\138\161\232\183\157\231\166\187\230\160\161\233\170\140\229\164\177\232\180\165\239\188\140\228\184\141\229\144\136\230\179\149", Lib.getPosDistance(damageInfo.targetPos, curTargetPos), Lib.getPosDistance(damageInfo.sourcePos, curSourcePos))
      return
    end
    if isPlayerAtt then
      weaponHurtValue, weaponLevel, isMelee = WeaponServer:export_getWeaponHurtValue(damageInfo.weaponId, distance, damageInfo.hurtType, damageInfo.attackCount, attackEntity, packet.skillJsonConf)
    else
      weaponHurtValue, weaponLevel = VehicleServer:export_getVehicleHurtValue(damageInfo.vehicleId, damageInfo.hurtType)
    end
    local changeValue = 0
    local vehicleExplodeScale = 1
    local hurtEntityPos = {}
    local isHitPlayer = false
    local isDoorDead
    local hurtATM = false
    local ATMBroken = false
    if damageInfo.hurtType == Define.HIT_BOX_TYPE.VEHICLE then
      vehicleExplodeScale = entity:cfg().vehicleExplodeScale or 1
      hurtEntityPos = entity:getPosition()
      local cfgId = entity:getVehicleCfgId()
      local cfg = VehicleBaseConfig:getCfgById(cfgId)
      local defense = cfg.vehicle_defense
      local level = cfg.vehicle_defence_lv
      local hurtValue = calculateHurtValue(weaponHurtValue, weaponLevel, level, defense)
      changeValue = entity:changeHp(-hurtValue)
      local attacker
      local vehicleOwner = Game.GetPlayerByUserId(entity:getVehicleOwner())
      if attackEntity.isPlayer then
        attacker = attackEntity
      elseif attackEntity:cfg().isTrolley then
        local player = Game.GetPlayerByUserId(attackEntity:getVehicleOwner())
        if player and player:isValid() then
          attacker = player
        end
      end
      if attacker and attacker:isValid() and vehicleOwner and vehicleOwner:isValid() and attacker:trySendHitVehicleMsg(vehicleOwner, damageInfo.hurtObjID) then
        attacker:recordHitVehicleTime(damageInfo.hurtObjID)
      end
    elseif damageInfo.hurtType == Define.HIT_BOX_TYPE.DOOR and damageInfo.weaponId then
      local door = entity
      local isDoorDestroyed = door:getBastionOwnerId() == nil and door:ndp_getStatus() == Define.NPCDoor.Status.Damaged or door:bdp_getStatus() == Define.Bastion.Defense.Status.Damaged
      if not isDoorDestroyed then
        if door:getBastionOwnerId() == nil then
          local defenseLevel = door:ndp_getDefenseLevel()
          local defense = door:ndp_getDefense()
          local hurtValue = calculateHurtValue(weaponHurtValue, weaponLevel, defenseLevel, defense)
          changeValue = door:ndp_takeDamage(hurtValue, damageInfo.attackObjID)
          isDoorDead = door:ndp_getStatus() == Define.NPCDoor.Status.Damaged
        else
          local defenseLevel = door:bdp_getDefenseLevel()
          local defense = door:bdp_getDefense()
          local hurtValue = calculateHurtValue(weaponHurtValue, weaponLevel, defenseLevel, defense)
          changeValue = door:bdp_takeDamage(hurtValue, damageInfo.attackObjID)
          isDoorDead = door:bdp_getStatus() == Define.Bastion.Defense.Status.Damaged
        end
        if isDoorDead then
          Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypeKill, Define.PassCardQuestKillType.QuestKillDoor, damageInfo.attackObjID, 1)
        end
      end
    elseif damageInfo.hurtType == Define.HIT_BOX_TYPE.ATM or damageInfo.hurtType == Define.HIT_BOX_TYPE.ATM_NPC then
      if entity:getATMState() == Define.ATM_STATE.ST_NORMAL then
        entity:setATMHurtStamp(os.time())
        hurtATM = true
        hurtEntityPos = entity:getPosition()
        changeValue = weaponHurtValue
        if damageInfo.hurtType == Define.HIT_BOX_TYPE.ATM then
          entity:playATMHurtAction()
          entity:dropMoney(false)
          entity:checkATMState()
        elseif damageInfo.hurtType == Define.HIT_BOX_TYPE.ATM_NPC then
          local hurtValue = calculateHurtValue(weaponHurtValue, weaponLevel, 1, 0)
          changeValue = entity:changeHp(-hurtValue)
          entity:playAMTAction(entity:cfg().action.hurt)
        end
        if entity:getATMState() == Define.ATM_STATE.ST_DEAD and damageInfo.hurtType == Define.HIT_BOX_TYPE.ATM then
          Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypeKill, Define.PassCardQuestKillType.QuestKillATM, damageInfo.attackObjID, 1)
          ATMBroken = true
        end
        local reportData = {}
        reportData.atm_hp = entity:getATMCurMoney()
        reportData.damage_means = damageInfo.weaponId
        reportData.atm_id = entity:getATMCfgId()
        self:evt_reportEvent(Define.EventTracking.Type.ATMSet, reportData, true)
      end
    elseif damageInfo.hurtType then
      local roleDefense = World.cfg.playerAttrs.roleDefense
      local hurtValue = calculateHurtValue(weaponHurtValue, weaponLevel, 1, roleDefense)
      changeValue = entity:changeHp(-hurtValue)
      entity:beTeabagAction(attackEntity)
      isHitPlayer = true
      if entity:getIsDead() then
        attackEntity:addKillPlayerDict(entity.platformUserId)
        Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypeKill, Define.PassCardQuestKillType.QuestKillPlayer, damageInfo.attackObjID, 1)
      end
    end
    local platformUserId = attackEntity.platformUserId and attackEntity:getVehicleOwner()
    entity:recordHurtData(damageInfo.weaponId or damageInfo.vehicleId, changeValue, platformUserId)
    if damageInfo.isKickATM and hurtATM then
    elseif isMelee then
      attackEntity.weapon:cutMeleeCount()
    end
    if changeValue ~= 0 or hurtATM then
      local hp = entity.getCurHp and entity:getCurHp() or 1
      local hurtInfo = {}
      hurtInfo.damagePos = damageInfo.damagePos
      hurtInfo.sourcePos = damageInfo.sourcePos
      hurtInfo.attackObjID = damageInfo.attackObjID
      hurtInfo.hurtObjID = damageInfo.hurtObjID
      hurtInfo.hurt = changeValue
      hurtInfo.curHp = hp
      hurtInfo.hurtType = damageInfo.hurtType
      hurtInfo.isVehicle = damageInfo.hurtType == Define.HIT_BOX_TYPE.VEHICLE
      hurtInfo.vehicleExplodeScale = vehicleExplodeScale
      hurtInfo.isMeleeAttack = isMelee
      hurtInfo.hurtEntityPos = hurtEntityPos
      hurtInfo.isPlayerAtt = isPlayerAtt
      hurtInfo.isATMBroken = ATMBroken
      if isPlayerAtt then
        hurtInfo.hitSound = "vehicle_gun_hit"
      else
        hurtInfo.hitSound = "vehicle_clash"
      end
      if entity.getIsDead and entity:getIsDead() and not hurtATM then
        hurtInfo.isDead = true
        local fromName = attackEntity:getName()
        local hurtEntity = World.CurWorld:getEntity(hurtInfo.hurtObjID)
        if hurtEntity then
          local hurtName = hurtEntity:getName()
          local weaponName = ""
          if isPlayerAtt then
            weaponName = attackEntity.weapon:getName()
          else
            local useCarInf = attackEntity:getInUseCar()
            if useCarInf then
              local vehicleEntity = World.CurWorld:getEntity(useCarInf.objId)
              if vehicleEntity and vehicleEntity:isValid() then
                local cfg = VehicleBaseConfig:getCfgById(vehicleEntity:getVehicleCfgId())
                if cfg then
                  weaponName = cfg.vehicle_name
                end
              end
            end
          end
          hurtInfo.deadTips = {
            fromName = fromName,
            hurtName = hurtName,
            weaponName = weaponName
          }
        end
      end
      self:sendPacketToTracking({pid = "onBeDamage", hurtInfo = hurtInfo}, true)
      if (isMelee or not isPlayerAtt) and isHitPlayer and entity:canBeHitBack() then
        self:hitBack(entity)
      end
      self:recordDamage(damageInfo, changeValue)
      local damage_type = isPlayerAtt and 0 or 1
      if not isPlayerAtt and damageInfo.hurtType == Define.HIT_BOX_TYPE.VEHICLE then
        damage_type = 2
      end
      local damage_means = damageInfo.weaponId or damageInfo.vehicleId
      if isDoorDead then
        self:reportDoorDie(entity, damage_type, damage_means)
        local ownerId = entity:getBastionOwnerId()
        local player = Game.GetPlayerByUserId(ownerId)
        player:reportDoorBeKill(entity, damage_type, damage_means, platformUserId)
      elseif entity:getIsDead() then
        local isCar = damageInfo.hurtType == Define.HIT_BOX_TYPE.VEHICLE
        if isHitPlayer then
          self:reportPlayerDie(entity, damage_type, damage_means)
          entity:reportPlayerBeKill(entity, damage_type, damage_means, platformUserId)
        elseif isCar then
          self:reportCarDie(entity, damage_type, damage_means)
          local ownerId = entity:getVehicleOwner()
          local player = Game.GetPlayerByUserId(ownerId)
          if player and player:isValid() then
            player:reportCarBeKill(entity, damage_type, damage_means, platformUserId)
          end
        end
      end
      if entity.getIsDead and entity:getIsDead() then
        entity:onDie()
      end
    end
  end
end

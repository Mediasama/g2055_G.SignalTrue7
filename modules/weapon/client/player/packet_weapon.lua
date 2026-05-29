local SoundConfig = T(Config, "SoundConfig")
local WeaponConfig = require("common.config.weapon_config")
local VehicleHelper = T(Lib, "VehicleHelper")
local WeaponClient = T(Lib, "WeaponClient")
local handles = T(Player, "PackageHandlers")

function handles:ChangeWeapon(packet)
  local id = packet.id
  self:changeWeapon(id)
end

function handles:onBeDamage(packet)
  local hurtInfo = packet.hurtInfo
  local hurtObjID = hurtInfo.hurtObjID
  local attackObjID = hurtInfo.attackObjID
  local hurtEntity = World.CurWorld:getEntity(hurtInfo.hurtObjID)
  if hurtInfo.isDead and hurtInfo.isVehicle then
    VehicleHelper:vehicleExplode(hurtInfo)
    return
  end
  if not hurtEntity or not hurtEntity:isValid() then
    return
  end
  if hurtInfo.isPlayerAtt then
    if hurtInfo.isVehicle then
      VehicleHelper:vehicleHurt(hurtInfo)
    elseif hurtInfo.hurtType == Define.HIT_BOX_TYPE.ATM or hurtInfo.hurtType == Define.HIT_BOX_TYPE.ATM_NPC then
      local hurt = hurtInfo.hurt
      self:showHurtEffect(hurtEntity, hurt, attackObjID)
      if hurtInfo.isATMBroken then
        hurtEntity:ATMExplode(hurtInfo)
      end
      if attackObjID == Me.objID then
        Me:playSoundByKey("g2055_ATM_hit")
      end
    else
      if hurtObjID == Me.objID then
        Lib.emitEvent(Event.EVENT_ON_HURT, hurtInfo.sourcePos)
        if hurtInfo.hurtType == Define.HIT_BOX_TYPE.HEAD then
          Me:playSoundByKey("g2055_battle_getHitCritical")
        else
          Me:playSoundByKey("g2055_battle_getHitNormal")
        end
        self:setHurtEnemyName(hurtInfo.attackObjID)
        Me:doHurtMoveSpeed()
      else
        local hurt = hurtInfo.hurt
        self:showHurtEffect(hurtEntity, hurt, attackObjID)
        if attackObjID == Me.objID then
          if not hurtInfo.isMeleeAttack then
            if hurtInfo.hurtType == Define.HIT_BOX_TYPE.HEAD then
              Me:playSoundByKey("g2055_battle_hitCritical")
            else
              Me:playSoundByKey("g2055_battle_hitNormal")
            end
          end
          Lib.emitEvent(Event.EVENT_ROGUELIKE_ENEMY_HURT, 3)
        end
      end
      if hurtInfo.isDead then
        WeaponClient:export_handlePlayerDead(hurtInfo)
      end
    end
  elseif hurtInfo.isVehicle then
    VehicleHelper:vehicleHurt(hurtInfo)
  else
    if hurtObjID == Me.objID then
      Lib.emitEvent(Event.EVENT_ON_HURT, hurtInfo.sourcePos)
      Me:playSoundByKey(hurtInfo.hitSound)
      self:setHurtEnemyName(hurtInfo.attackObjID)
    else
      local hurt = hurtInfo.hurt
      self:showHurtEffect(hurtEntity, hurt, attackObjID)
      if attackObjID == Me.objID then
        Me:playSoundByKey(hurtInfo.hitSound)
        Lib.emitEvent(Event.EVENT_ROGUELIKE_ENEMY_HURT, 3)
      end
    end
    if hurtInfo.isDead then
      WeaponClient:export_handlePlayerDead(hurtInfo)
    end
  end
end

function handles:SyncWeaponData(packet)
  local weaponData = packet.weaponData
  Me:setWeaponData(weaponData)
  Lib.emitEvent(Event.EVENT_SYNC_WEAPON_DATA, weaponData)
end

function handles:showDropItem(packet)
  Lib.emitEvent(Event.EVENT_IN_WEAPON, packet.dropData)
end

function handles:receiveMatchData(packet)
  Lib.emitEvent(Event.EVENT_MATCH_DATA, packet.mathData)
end

function handles:receiveBattleData(packet)
  Lib.emitEvent(Event.EVENT_BATTLE_DATA, packet.battleData)
end

local BattleNode = require("client.battle_node")

function handles:receiveDropData(packet)
  do return end
  local oldDropItem = self.dropItems or {}
  self.dropItems = {}
  self.dropData = packet.dropData
  if Me.dropItems then
    for i, node in ipairs(self.dropItems) do
      node:removeFromParent()
    end
  end
  Me.dropItems = {}
  for i, node in ipairs(oldDropItem) do
    local isHas
    for _, odata in ipairs(self.dropData) do
      if node.objID == odata.objID then
        isHas = true
      end
    end
    if isHas then
      table.insert(self.dropItems, node)
    else
      node:removeFromParent()
    end
  end
  local parent = World.CurMap:getScene():getRoot()
  for i, data in ipairs(self.dropData) do
    local isHas
    for _, node in ipairs(oldDropItem) do
      if data.objID == node.objID then
        isHas = true
      end
    end
    if not isHas then
      local node = BattleNode.Create()
      node:setObjID(data.objID)
      parent:addChild(node)
      local conf = WeaponConfig:getCfgById(data.itemData.linkID)
      local actorName = conf.part.gun .. ".actor"
      node:setActor(actorName)
      print("data.pos data.pos =", data.pos.x, data.pos.z)
      node:setLocalPosition(data.pos)
      table.insert(Me.dropItems, node)
    end
  end
  Lib.emitEvent(Event.EVENT_DROP_DATA)
end

function handles:onEntityRevive(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity then
    if entity.objID == Me.objID then
      Blockman.instance:control().enable = true
      local CameraManager = T(Lib, "CameraManager")
      CameraManager:resetCamera()
      self:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
    end
    if entity.weapon then
      entity.weapon:initAction()
      entity:refreshUpperAction()
    end
  end
end

function handles:playerAction(packet)
  local data = packet.data
  local entity = World.CurWorld:getEntity(data.objID)
  if entity and (not packet.includeMe and entity.objID ~= Me.objID or packet.includeMe) then
    if data.isOnce then
      entity:updateUpperAction(data.actionName, data.time)
    else
      entity:updateUpperAction1(data.actionName, data.time, true, 0, true)
    end
  end
end

function handles:initPlayerAction(packet)
end

local WeaponEffectHelper = T(Lib, "WeaponEffectHelper")
local WeaponConfig = T(Config, "WeaponConfig")

function handles:onBulletEffect(packet)
  local hitEffectInfo, bulletEffectInfo = packet.hitEffectInfo, packet.bulletEffectInfo
  for i, v in pairs(bulletEffectInfo) do
    if v.objID ~= Me.objID then
      local jsonCfg = WeaponConfig:getWeaponJsonById(v.weaponId)
      local bulletConf = jsonCfg.bullet
      WeaponEffectHelper:showBulletEffect(bulletConf.effectName, bulletConf, v.beginPos, v.endPos, v.rotation)
    end
  end
  for i, v in pairs(hitEffectInfo) do
    if v.objID ~= Me.objID then
      WeaponEffectHelper:showHitEffect(v.effect, v.pos, v.time)
    end
  end
end

function handles:onMissileInfo(packet)
  print("handles:onMissileInfo(packet)")
  local missileInfo = packet.missileInfo
  for i, v in pairs(missileInfo) do
    WeaponEffectHelper:createMissile(v)
  end
end

function handles:showMyMissileEffect(packet)
  print("handles:showMyMissileEffect(packet)")
  WeaponEffectHelper:createMissile(packet.missileInfo)
end

function handles:DropItemSpawn(packet)
  local dropitem = DropItemClient.Create(packet.objID, packet.pos, assert(Item.DeseriItem(packet.item)), packet.moveSpeed, packet.moveTime, packet.guardTime)
  dropitem.itemData = packet.itemData
end

function handles:syncTargetForwardClient(packet)
  print("\229\174\162\230\136\183\231\171\175\239\188\140\232\162\171\229\135\187\233\128\128", packet.pos.x, packet.pos.y, packet.pos.z)
  self:setForceMove(packet.pos, 2)
end

local function checkActionPriority(upperAction)
  if type(upperAction) ~= "string" then
    return true
  end
  if upperAction:find("idle") then
    return true
  end
  return false
end

function handles:syncForceMoveToAll(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity and entity:isValid() then
    print("handles:syncForceMoveToAll(packet)")
    entity:setForceMove(packet.pos, packet.time)
    local cfg = entity:cfg()
    local upperAction = entity:getBaseAction()
    local hurtAction = cfg.hurtAction
    local action = hurtAction and hurtAction.action
    if action and action ~= "" and checkActionPriority(upperAction) then
      entity:updateUpperAction(action, hurtAction.time, false)
    end
  end
end

function handles:onMeleeTwinkle(packet)
  self.twinkleWeapons = self.twinkleWeapons or {}
  if not self.twinkleWeapons[packet.guid] then
    local msg = Lang:toText("weapon.readyToBroken" or "\229\189\147\229\137\141\230\173\166\229\153\168\229\191\171\230\141\159\229\157\143\228\186\134")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    self.twinkleWeapons[packet.guid] = true
  end
  Lib.emitEvent(Event.EVENT_MELEE_TWINKLE, packet.index)
end

function handles:onMeleeDestroy(packet)
  local msg = Lang:toText("weapon.isBroken" or "\230\173\166\229\153\168\229\183\178\230\141\159\230\175\129")
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  Lib.emitEvent(Event.EVENT_MELEE_DESTROY, packet.index, packet.newIndex)
end

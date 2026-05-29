local DoorsConfig = T(Config, "DoorsConfig")
local EntityBastionClient = Entity
local BastionConfig = T(Config, "BastionConfig")

function EntityBastionClient:updateBastionFacilityInfo()
  local entity = self
  if entity:getBastionFacilityType() == Define.Bastion.Facility.Type.None then
    return
  end
  if entity:getBastionFacilityType() == Define.Bastion.Facility.Type.DoorPlate then
    local ownerId = entity:getBastionOwnerId()
    if ownerId then
      local param = {}
      param.id = entity:getBastionUid()
      param.ownerId = ownerId
      param.position = entity:getPosition()
      param.rotation = entity:getRotation()
      Me:updateDoorPlate(param)
    else
      entity:setShowName("")
      local id = entity:getBastionUid()
      Me:removeDoorPlate(id)
    end
    return
  else
    entity:setShowName("")
  end
end

function EntityBastionClient:updateFacilityEffect()
  local entity = self
  local cfg = entity:cfg()
  if cfg then
    local effect = cfg.facilityEffect
    local ownerId = entity:getBastionOwnerId()
    local isUnlock
    if entity:getBastionFacilityType() == Define.Bastion.Facility.Type.Armory then
      local owner = Game.GetPlayerByUserId(ownerId)
      if owner then
        local player = World.CurWorld:getEntity(owner.objID)
        if player and player:isValid() then
          isUnlock = player:getBastionArmoryLevel() > 0
        end
      end
    else
      isUnlock = true
    end
    if effect then
      if ownerId and isUnlock then
        self:createFacilityEffect(effect)
      else
        self:removeFacilityEffect()
      end
    end
  end
end

function EntityBastionClient:createFacilityEffect(param)
  if self.FacilityEffect or not param then
    return
  end
  local effectName = param.path or "g2055_dropEffect.effect"
  local cvs = BastionConfig:getCfgById(self:getFacilityCfgID())
  if not cvs then
    return
  end
  local position, rotation
  if self:getBastionFacilityType() == Define.Bastion.Facility.Type.Armory then
    position = cvs.armoryEffect.position
    rotation = cvs.armoryEffect.rotation
  elseif self:getBastionFacilityType() == Define.Bastion.Facility.Type.Closet then
    position = cvs.closetEffect.position
    rotation = cvs.closetEffect.rotation
  elseif self:getBastionFacilityType() == Define.Bastion.Facility.Type.Vault then
    position = cvs.vaultEffect.position
    rotation = cvs.vaultEffect.rotation
  elseif self:getBastionFacilityType() == Define.Bastion.Facility.Type.ToolKit then
    position = cvs.toolkitEffect.position
    rotation = cvs.toolkitEffect.rotation
  end
  if not position or not rotation then
    return
  end
  local effectRotation = Vector3.new(rotation.x, rotation.y, rotation.z)
  self.FacilityEffect = EffectNode.Load(effectName)
  self.FacilityEffect:setLocalPosition(position)
  self.FacilityEffect:setLocalQuaternion(Quaternion.fromEulerAngleVector(effectRotation))
  self.FacilityEffect:setMaxViewDistance(param.viewDistance or 20)
  local parent = World.CurMap:getScene():getRoot()
  parent:addChild(self.FacilityEffect)
end

Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objId)
  local entity = World.CurWorld:getEntity(objId)
  if entity and entity:isValid() and entity.FacilityEffect then
    entity:removeFacilityEffect()
  end
end)

function EntityBastionClient:removeFacilityEffect()
  if not self.FacilityEffect then
    return
  end
  local parent = World.CurMap:getScene():getRoot()
  parent:removeChild(self.FacilityEffect)
  self.FacilityEffect = nil
end

function EntityBastionClient:updateBastionDefenseInfo()
  local entity = self
  if entity:getBastionDefenseType() == Define.Bastion.Defense.Type.None then
    return
  end
  local property = entity:brp_getDefensePropertyCopy()
  local hp = property.hp or 0
  local status = property.status or Define.Bastion.Defense.Status.None
  local holdDoorCount = entity:brp_getHoldDoorCount()
  if status == Define.Bastion.Defense.Status.Normal then
    local cfg = self:cfg() or {}
    local defenseCollider = cfg.defenseCollider or {}
    local boundingVolume = defenseCollider[status] or {
      collider = {type = "Empty"}
    }
    self:setCollisionGroup(Define.COLLISION_GROUP.BUILDING)
  elseif status == Define.Bastion.Defense.Status.Damaged then
    local cfg = self:cfg() or {}
    local defenseCollider = cfg.defenseCollider or {}
    local boundingVolume = defenseCollider[status] or {
      collider = {type = "Empty"}
    }
    self:setCollisionGroup(0)
  elseif status == Define.Bastion.Defense.Status.Hacked then
    local cfg = self:cfg() or {}
    local defenseCollider = cfg.defenseCollider or {}
    local boundingVolume = defenseCollider[status] or {
      collider = {type = "Empty"}
    }
    self:setCollisionGroup(0)
  end
end

function EntityBastionClient:updateUnlockDoorStatus()
  if not self.isPlayer then
    return
  end
  if self.platformUserId ~= Me.platformUserId then
    return
  end
  local hackObjID = self:bhp_getHackObjID()
  if hackObjID then
    local door = World.CurWorld:getObject(hackObjID)
    if door and door:isValid() then
      Blockman.instance:control().enable = false
      if self.lastHackObjID ~= hackObjID then
        Lib.emitEvent(Event.EVENT_ENTER_UNLOCK_DOOR)
      end
      local ownerId = door:getBastionOwnerId()
      if ownerId then
        local property = door:brp_getDefensePropertyCopy() or {}
        local doorID = property.id
        local config = DoorsConfig:getCfgById(doorID)
        if config then
          if self.unlockSoundId then
            Me:stopSound(self.unlockSoundId)
            self.unlockSoundId = nil
          end
          self.unlockSoundId = Me:playSoundByKey(config.startHackSound)
        end
        local param = {}
        param.hackInfo = door:brp_getHackerInfo(Me.platformUserId)
        param.doorInfo = {objID = hackObjID}
        param.doorConfig = config
        UI:openCustomWindow("./UI/bastion/win_bastion_pick_lock", nil, param)
      else
        local npcDoor = door
        local doorID = npcDoor:ndp_getConfigID()
        local config = DoorsConfig:getCfgById(doorID)
        if config then
          if self.unlockSoundId then
            Me:stopSound(self.unlockSoundId)
            self.unlockSoundId = nil
          end
          self.unlockSoundId = Me:playSoundByKey(config.startHackSound)
        end
        local param = {}
        param.hackInfo = npcDoor:ndp_getHackerInfo(Me.platformUserId)
        param.doorInfo = {objID = hackObjID}
        param.doorConfig = config
        UI:openCustomWindow("./UI/bastion/win_bastion_pick_npc_lock", nil, param)
      end
    else
      if self.unlockSoundId then
        Me:stopSound(self.unlockSoundId)
        self.unlockSoundId = nil
      end
      if Me:getCurHp() > 0 then
        Blockman.instance:control().enable = true
      end
      if self.lastHackObjID ~= hackObjID then
        Lib.emitEvent(Event.EVENT_EXIT_UNLOCK_DOOR)
      end
      UI:closeWnd("./UI/bastion/win_bastion_pick_lock")
      UI:closeWnd("./UI/bastion/win_bastion_pick_npc_lock")
    end
  else
    if self.unlockSoundId then
      Me:stopSound(self.unlockSoundId)
      self.unlockSoundId = nil
    end
    if Me:getCurHp() > 0 then
      Blockman.instance:control().enable = true
    end
    if self.lastHackObjID ~= hackObjID then
      Lib.emitEvent(Event.EVENT_EXIT_UNLOCK_DOOR)
    end
    UI:closeWnd("./UI/bastion/win_bastion_pick_lock")
    UI:closeWnd("./UI/bastion/win_bastion_pick_npc_lock")
  end
  self.lastHackObjID = hackObjID
end

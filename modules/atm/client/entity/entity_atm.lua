local Entity = _ENV.Entity
local EntityColliderHelper = T(Lib, "EntityColliderHelper")
local SoundConfig = T(Config, "SoundConfig")
Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
  local entity = World.CurWorld:getEntity(objID)
  if entity and entity:isValid() then
    local cfg = entity:cfg()
    if cfg.isATM then
      local collider = Instance.Create("CollisionObject")
      collider:setCanBlockCamera(false)
      collider:setShape(cfg.collider)
      collider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
      collider.boxType = Define.COLLIDER_BOX_TYPE.HIT_BOX
      collider.parentObjID = entity.objID
      local ATMType = cfg.ATMType or Define.ATM_TYPE.ATM
      collider.hitBoxType = ATMType == Define.ATM_TYPE.ATM and Define.HIT_BOX_TYPE.ATM or Define.HIT_BOX_TYPE.ATM_NPC
      EntityColliderHelper:addEntityCollisionBoxStatic(entity, collider, nil)
      local pos = Lib.copy(entity:getPosition())
      pos.y = pos.y + cfg.collider.extent.y / 2
      collider:setLocalPosition(pos)
      collider = Instance.Create("CollisionObject")
      collider:setCanBlockCamera(false)
      collider:setShape(cfg.colliderTrigger)
      collider:setCollisionGroup(Define.COLLISION_GROUP.VEHICLE_TRIGGER)
      collider:setLocalPosition({
        x = 0,
        y = cfg.collider.extent.y / 2,
        z = 0
      })
      collider.parentObjID = entity.objID
      collider:connect("touch_enter", entity, "onTriggerEnterATM")
      collider:connect("touch_leave", entity, "onTriggerExitATM")
      EntityColliderHelper:addEntityCollisionBoxStatic(entity, collider, entity:getPosition())
    end
  end
end)

function Entity:onTriggerEnterATM(target, typename)
  if typename ~= "Entity" then
    return
  end
  if target.isPlayer and target.platformUserId == Me.platformUserId then
    Lib.emitEvent(Event.EVENT_NEAR_ATM)
  end
end

function Entity:onTriggerExitATM(target, typename)
  if typename ~= "Entity" then
    return
  end
  if target.isPlayer and target.platformUserId == Me.platformUserId then
    Lib.emitEvent(Event.EVENT_LEAVE_ATM)
  end
end

function Entity:ATMExplode(hurtInfo)
  if not hurtInfo then
    return
  end
  local sound = SoundConfig:getSound("g2055_ATM_broken")
  local volume = sound.volume or 1
  local id = TdAudioEngine.Instance():play3dSound(sound.sound, hurtInfo.hurtEntityPos, false, 1, 1.0, 100.0)
  TdAudioEngine.Instance():setSoundsVolume(id, volume)
  TdAudioEngine.Instance():set3DMinMaxDistance(id, 1, 20)
  local timeScale = 1
  local scale = 1
  local explodeEffect = self:cfg().ExplodeEffect or "g2055_vehical_blast_effect.effect"
  Blockman.instance:playPluginEffectByPos(explodeEffect, hurtInfo.hurtEntityPos, timeScale, 0, 10000, Lib.v3(scale, scale, scale))
end

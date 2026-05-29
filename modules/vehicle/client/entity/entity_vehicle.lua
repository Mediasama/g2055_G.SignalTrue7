local Entity = _ENV.Entity
local EntityColliderHelper = T(Lib, "EntityColliderHelper")
local Player = _ENV.Player
local jetEffectIdleKey = "jetEffectIdle"
local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(player)
  if player.objID == Me.objID then
    Me:doSetProp("newTouchCollisionMask", Define.PLAYER_TOUCH_GROUP)
  end
end)
Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
  local entity = World.CurWorld:getEntity(objID)
  if entity and entity:isValid() then
    local cfg = entity:cfg()
    if cfg.isTrolley then
      local collider = Instance.Create("CollisionObject")
      collider:setCanBlockCamera(false)
      collider:setShape(cfg.collider)
      collider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
      collider:setLocalPosition({
        x = 0,
        y = cfg.collider.extent.y / 2,
        z = 0
      })
      collider.boxType = Define.COLLIDER_BOX_TYPE.HIT_BOX
      collider.parentObjID = entity.objID
      collider.hitBoxType = Define.HIT_BOX_TYPE.VEHICLE
      EntityColliderHelper:addEntityCollisionBox(entity, collider, nil)
      collider = Instance.Create("CollisionObject")
      collider:setCanBlockCamera(false)
      collider:setShape(cfg.triggerCollider)
      collider:setCollisionGroup(Define.COLLISION_GROUP.VEHICLE_TRIGGER)
      collider:setLocalPosition({
        x = 0,
        y = cfg.triggerCollider.extent.y / 2,
        z = 0
      })
      collider.parentObjID = entity.objID
      collider:connect("touch_enter", entity, "onTriggerEnterVehicle")
      collider:connect("touch_leave", entity, "onTriggerExitVehicle")
      EntityColliderHelper:addEntityCollisionBox(entity, collider, nil)
    end
  end
end)

function Entity:onTriggerEnterVehicle(target, typename)
  Lib.logInfo(">>>>>>>>>>>>>>>>>>>>>>>> handler:onTriggerEnterVehicle", self.objID, self:cfg().name)
  if typename ~= "Entity" then
    return
  end
  if target.isPlayer and target.platformUserId == Me.platformUserId then
    Player:playerNearVehicle({
      vehicleId = self.objID
    })
  end
end

function Entity:onTriggerExitVehicle(target, typename)
  if typename ~= "Entity" then
    return
  end
  if target.isPlayer and target.platformUserId == Me.platformUserId then
    if self:isValid() then
      Player:playerLeaveVehicle({
        vehicleId = self.objID
      })
    else
      print(">>>>>>>>> Entity:onCollisionExit ,car is die ")
    end
  end
end

Lib.subscribeEvent(Event.EVENT_HAS_PASSENGER, function(value, carId)
  local vehicle = World.CurWorld:getEntity(carId)
  if vehicle and vehicle:isValid() then
    if 0 < value then
      vehicle:addJetEffect()
    else
      vehicle:clearJetEffect()
    end
  end
end)
Lib.subscribeEvent(Event.EVENT_VEHICLE_STATUS_CHANGE, function(vehicle, newState, oldState)
  if not vehicle:isValid() then
    return
  end
  if Define.EntityMoveStatus[newState] == "RUN" then
    vehicle:clearJetEffect()
  elseif Define.EntityMoveStatus[newState] == "IDLE" then
    local passengers = vehicle:data("passengers")
    if next(passengers) ~= nil then
      vehicle:addJetEffect()
    end
  end
end)

function Entity:addJetEffect()
  if not self:isValid() then
    return
  end
  local cvs = VehicleBaseConfig:getCfgById(self:getVehicleCfgId())
  if not cvs then
    return
  end
  self:clearJetEffect()
  local exhaustPos = self:cfg().exhaustPos
  local key = jetEffectIdleKey
  local effect = cvs.vehicle_exhaust_hold
  local position = exhaustPos and Vector3.new(exhaustPos.x, exhaustPos.y, exhaustPos.z) or Vector3.new(0, 0.5, -3)
  local scale = Vector3.new(1, 1, 1)
  local yaw = 0
  self:addEffect(key, effect, false, position, yaw, scale)
end

function Entity:clearJetEffect()
  if not self:isValid() then
    print(">>>>>>>>>>>>>>>>>>>>>> Entity:clearJetEffect(),Entity die")
    return
  end
  self:delEffect(jetEffectIdleKey)
end

function Entity:canShowInteractIcon()
  if not self:isValid() then
    return false
  end
  local passengers = self:data("passengers")
  if next(passengers) ~= nil then
    return false
  end
  return true
end

local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local CarConfig = T(Config, "VehicleBaseConfig")
local LuaTimer = T(Lib, "LuaTimer")
local WeaponServer = T(Lib, "WeaponServer")
local VehicleManager = T(Lib, "VehicleManager")

function EntityServer:startDestroyTimer()
  local destroyDelayTime = World.cfg.vehicle.vehicleDestroyTime
  self:cancelDestroyTimer()
  self.destroyTimer = LuaTimer:schedule(function()
    local cfg = CarConfig:getCfgById(self:getVehicleCfgId())
    if cfg and cfg.vehicle_is_lock == 1 then
      local canDestroy = true
      local owner = Game.GetPlayerByUserId(self:getVehicleOwner())
      if owner ~= nil and owner:isValid() then
        canDestroy = false
      end
      if self:getIsVehicleUnlocking() then
        canDestroy = false
      end
      if not canDestroy then
        self:startDestroyTimer()
        return
      end
    end
    self:cancelDestroyTimer()
    if self:isValid() then
      self:destroyVehicleByTimer()
    end
  end, (destroyDelayTime and destroyDelayTime or 60) * 1000)
end

function EntityServer:destroyVehicleByTimer()
  local owner = Game.GetPlayerByUserId(self:getVehicleOwner())
  if owner and owner:isValid() then
    owner:removeVehicleInBag(self)
    VehicleManager:vehicleLostReport(Define.ReportCostAccessType.SystemRecovery, owner, self:getVehicleCfgId())
  end
  self:destroy()
end

function EntityServer:cancelDestroyTimer()
  if self.destroyTimer then
    LuaTimer:cancel(self.destroyTimer)
  end
end

function EntityServer:addVehicleBuffByState(state)
  if not self:cfg().statusBuff then
    return
  end
  local passengers = self:data("passengers")
  if next(passengers) == nil then
    return
  end
  local buffName = self:cfg().statusBuff[state]
  if buffName then
    self:addBuff(buffName)
  end
end

function EntityServer:clearVehicleBuff()
  if not self:cfg().statusBuff then
    return
  end
  for _, v in pairs(self:cfg().statusBuff) do
    self:removeTypeBuff("fullName", v)
  end
end

function EntityServer:unlockVehicleBegin(playerId)
end

function EntityServer:unlockVehicleEnd(playerId, isSuccess)
end

World.Timer(1, function()
  Lib.subscribeEvent(Event.EVENT_ENTITY_DEATH, function(objId, obj)
    if obj and obj:isValid() and obj:cfg().isTrolley then
      obj:onVehicleDie()
    end
  end)
end)

function EntityServer:onVehicleDie()
  if not self:isValid() or not self:cfg().isTrolley then
    return
  end
  local k, passengerId = next(self:data("passengers"))
  if passengerId ~= nil then
    local player = World.CurWorld:getEntity(passengerId)
    if player and player:isValid() then
      player:removeCurVehicle(player:getInUseCar())
      self:destroy()
    end
  else
    self:destroy()
  end
end

function EntityServer:onConnectVehicleCollideEvent()
  self:connect("touch_enter", self, "onVehicleCollisionEnter")
end

function EntityServer:onVehicleCollisionEnter(target, typename)
  if not (target and target:isValid() and self:isValid()) or typename ~= "Entity" then
    return
  end
  local car = target
  local cfg = car:cfg()
  if cfg.isTrolley then
    local speed = car:getCurSpeed()
    if speed < cfg.moveSpeed / 4 then
      return
    end
    local k, passengerId = next(car:data("passengers"))
    local passengerPlayer = World.CurWorld:getEntity(passengerId)
    if not passengerPlayer or not passengerPlayer:isValid() then
      return
    end
    local entity = self
    local hurtPlayerId
    if entity.isPlayer then
      hurtPlayerId = entity.platformUserId
    end
    if entity:cfg().canAttack and (hurtPlayerId == nil or car:getVehicleOwner() ~= hurtPlayerId) then
      local isVehicle = entity:cfg().isTrolley
      local info = {}
      info.damagePos = entity:getPosition()
      info.attackObjID = passengerId
      info.vehicleId = car:getVehicleCfgId()
      info.hurtObjID = entity.objID
      info.hurtType = isVehicle and Define.HIT_BOX_TYPE.VEHICLE or Define.HIT_BOX_TYPE.BODY
      info.sourcePos = car:getPosition()
      info.targetPos = entity:getPosition()
      WeaponServer:export_doDamage({damageInfo = info})
      VehicleManager:vehicleBumpReport(car, entity)
    end
  end
end

function EntityServer:getCurSpeed()
  if self.motion then
    return math.sqrt(self.motion.x * self.motion.x + self.motion.y * self.motion.y + self.motion.z * self.motion.z)
  else
    return 0
  end
end

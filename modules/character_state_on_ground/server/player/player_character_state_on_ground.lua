local Player = _ENV.Player

function Player:isPlayerInDieState()
  if self.dieSubState ~= nil or self:getCurState() == Define.CHARACTER_STATE_TYPE.DIE then
    return true
  end
  return false
end

function Player:checkBeThrowEnable(myRideTarget)
  if self.dieSubState == Define.DIE_SUB_STATE.BeCarried and myRideTarget == self.myRideTarget then
    return true
  end
  return false
end

function Player:checkBeCarryEnable(userId)
  if self.myRideTarget == nil and self.onGroundTrigger ~= nil and self.triggerPlayer[userId] then
    return true
  end
  return false
end

function Player:enableCarrierPlayer()
  if self:getCurState() == Define.CHARACTER_STATE_TYPE.DIE then
    return false
  end
  if self.myPassengers ~= nil or self.dieSubState ~= nil then
    return false
  end
  return true
end

function Player:getSceneParent()
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  return scene:getRoot()
end

function Player:createOnGroundBox()
  local triggerCollider = World.cfg.dieSubStateSetting.triggerCollider
  local collider = Instance.Create("CollisionObject")
  collider:setCanBlockCamera(false)
  collider:setShape(triggerCollider)
  collider:setCollisionGroup(Define.COLLISION_GROUP.TRIGGER)
  collider:setLocalPosition(self:getPosition())
  collider:connect("touch_enter", self, "onTriggerEnter")
  collider:connect("touch_leave", self, "onTriggerExit")
  local parent = self:getSceneParent()
  parent:addChild(collider)
  self.initOnGroundPos = self:getPosition()
  self.triggerPlayer = {}
  return collider
end

function Player:onTriggerEnter(target, typename)
  if target.objID == self.objID or typename ~= "Entity" or target.myPassengers or self.myRideTarget then
    return
  end
  if target.isPlayer then
    if not target:enableCarrierPlayer() or target:getCurState() == Define.CHARACTER_STATE_TYPE.DIE then
      return
    end
    self.triggerPlayer[target.platformUserId] = target.platformUserId
    target:sendPacket({
      pid = "onUpdateCarryBtn",
      param = {
        userId = self.platformUserId,
        triggerType = "Enter"
      }
    })
  end
end

function Player:onTriggerExit(target, typename)
  if target.objID == self.objID or typename ~= "Entity" or target.myPassengers or self.myRideTarget then
    return
  end
  if target.isPlayer then
    self.triggerPlayer[target.platformUserId] = nil
    target:sendPacket({
      pid = "onUpdateCarryBtn",
      param = {
        userId = self.platformUserId,
        triggerType = "Exit"
      }
    })
  end
end

local function getFaceDirect(entity)
  local dir = Lib.posAroundYaw({
    x = 0,
    y = 0,
    z = 1
  }, entity:getRotationYaw())
  return dir
end

local throwYOffset = 10

function Player:throwPlayer(userId)
  local passengers = Game.GetPlayerByUserId(userId)
  if passengers and passengers:isValid() and passengers:checkBeThrowEnable(self) then
    local desPos = getFaceDirect(self) * World.cfg.dieSubStateSetting.throwDis + self:getPosition()
    desPos.y = desPos.y - throwYOffset
    self.myPassengers = nil
    passengers:beThrow(desPos)
    self:playDieSubStateAction(Define.DIE_SUB_STATE.Throw)
    local reportData = {}
    reportData.double_action_type = Define.EventTracking.UseDoubleAction.ActionType.Throw
    reportData.action_time = os.time() - self.carryPlayerStartTime
    self:evt_reportEvent(Define.EventTracking.Type.UseDoubleAction, reportData, true)
    self:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
    return true
  end
  return false
end

function Player:beThrow(desPos)
  self:rideOn(nil, false)
  self.myRideTarget = nil
  self:setDieSubState(Define.DIE_SUB_STATE.BeThrow)
  self:sendPacketToTracking({
    objID = self.objID,
    pid = "onBeThrowForceMove",
    pos = desPos,
    time = World.cfg.dieSubStateSetting.throwMoveTime + 3
  }, true)
  self:setForceMove(desPos, World.cfg.dieSubStateSetting.throwMoveTime)
end

function Player:carryPlayer(userId)
  if not self:enableCarrierPlayer() then
    return false
  end
  local passengers = Game.GetPlayerByUserId(userId)
  if passengers and passengers:isValid() and passengers:checkBeCarryEnable(self.platformUserId) then
    self.myPassengers = passengers
    passengers:setBeCarriedOnState(self)
    self:changeState(Define.CHARACTER_STATE_TYPE.CARRY)
    self:sendPacket({
      pid = "onUpdateCarrySuccess",
      userId = userId
    })
    self.carryPlayerStartTime = os.time()
    self:resetDefaultWeapon()
    return true
  end
  return false
end

function Player:clearMyCarrier()
  if self.myPassengers then
    self:throwPlayer(self.myPassengers.platformUserId)
    self.myPassengers = nil
    self:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
  end
end

function Player:setBeCarriedOnState(rideTarget)
  self:setDieSubState(Define.DIE_SUB_STATE.BeCarried)
  local index = World.cfg.dieSubStateSetting.ridePos[Define.DIE_SUB_STATE.OnGround].rideIndex
  if self:getValue("autoHurtSelf") then
    index = World.cfg.dieSubStateSetting.ridePos[Define.DIE_SUB_STATE.AutoHurt].rideIndex
  end
  self:rideOn(rideTarget, false, index)
  self.myRideTarget = rideTarget
  self:exitOnGround()
end

function Player:exitOnGround()
  if self.onGroundTrigger then
    local parent = self:getSceneParent()
    parent:removeChild(self.onGroundTrigger)
    self.onGroundTrigger = nil
    if self.triggerPlayer then
      for k, v in pairs(self.triggerPlayer) do
        local target = Game.GetPlayerByUserId(v)
        if target and target:isValid() and target.myPassengers == nil then
          target:sendPacket({
            pid = "onUpdateCarryBtn",
            param = {
              userId = self.platformUserId,
              triggerType = "Exit"
            }
          })
        end
      end
    end
    self.triggerPlayer = {}
  end
end

function Player:setStateOnGround()
  if self.onGroundTrigger == nil then
    self.onGroundTrigger = self:createOnGroundBox()
    self:clearMyCarrier()
  end
end

function Player:updateStateOnGround()
  if self.onGroundTrigger == nil then
    return
  end
  local pos = self:getPosition()
  if pos.x ~= self.initOnGroundPos.x or self.initOnGroundPos.y ~= pos.y or self.initOnGroundPos.z ~= pos.z then
    self.initOnGroundPos = Lib.copy(self:getPosition())
    self.onGroundTrigger:setLocalPosition(self.initOnGroundPos)
  end
  return true
end

function Player:dieSubStatePlayerLogout()
  self:clearMyCarrier()
  self:clearDieSubState()
end

local Player = _ENV.Player

function Player:setDieSubState(st)
  if self.dieSubState == st then
    return
  end
  if st == Define.DIE_SUB_STATE.OnGround then
    self:resetDefaultWeapon()
    self:setStateOnGround()
    if self:getValue("autoHurtSelf") then
      self:playDieSubStateAction(Define.DIE_SUB_STATE.AutoHurt)
    else
      self:playDieSubStateAction(st)
    end
  elseif st == Define.DIE_SUB_STATE.BeCarried then
  elseif st == Define.DIE_SUB_STATE.BeThrow then
    self:playDieSubStateAction(self.prePreState)
  end
  if Define.DIE_SUB_STATE_REF_PLAYER_STATE[st] then
    self:changeState(Define.DIE_SUB_STATE_REF_PLAYER_STATE[st])
  end
  self.dieSubState = st
end

function Player:updateDieSubState()
  if self.dieSubState == nil or not self:isValid() then
    return
  end
  if self.dieSubState == Define.DIE_SUB_STATE.OnGround then
    self:updateStateOnGround()
  elseif self.dieSubState == Define.DIE_SUB_STATE.BeCarried then
  elseif self.dieSubState == Define.DIE_SUB_STATE.BeThrow and self.onGround then
    self:setDieSubState(Define.DIE_SUB_STATE.OnGround)
  end
  if self:getValue("autoHurtSelf") and World.Now() >= self.nextAutoHurtTime then
    self:changeHp(-World.cfg.dieSubStateSetting.autoHurtSelfHp)
    self:resetAutoHurtTime()
  end
  if self.dieSubStateInvincible and World.Now() >= self.invincibleTime then
    self.dieSubStateInvincible = false
  end
  self:checkReLife()
end

function Player:isDieSubStateInvincible()
  return self.dieSubStateInvincible
end

function Player:enableAutoReduceHp()
  if self:getValue("autoHurtSelf") then
    return false
  end
  return true
end

function Player:playDieSubStateAction(st)
  local actionData = World.cfg.dieSubStateSetting.actionMap[st]
  if actionData then
    self:pam_stopMotion()
    if st ~= Define.DIE_SUB_STATE.Throw then
      print("Player:playDieSubStateAction(st)")
      self:setActionIdle(actionData.action)
      return
    end
    local packet = {
      pid = "EntityPlayAction",
      objID = self.objID,
      action = actionData.action,
      time = actionData.time,
      refreshBaseAction = actionData.refreshBaseAction
    }
    self:sendPacketToTracking(packet, true)
  end
end

function Player:onEnterDieState()
  if self.dieSubState == nil then
    self:setDieSubState(Define.DIE_SUB_STATE.OnGround)
    self.totalHurtSelfHp = 0
    self.invincibleTime = World.cfg.dieSubStateSetting.invincibleTime + World.Now()
    self.dieSubStateInvincible = true
    self.nextAutoHurtTime = 0
    local addHp = 1 - self:getCurHp()
    self:changeHp(addHp)
    self.dieSubStateUpdateTimer = World.Timer(1, function()
      self:updateDieSubState()
      return true
    end)
  else
    Trigger.CheckTriggers(nil, Define.PLAYER_DIE_TRIGGER_EVENT, {player = self})
    self:clearDieSubState()
    self:setIsDead(true)
    self:onDie()
  end
end

function Player:resetAutoHurtTime()
  self.nextAutoHurtTime = World.Now() + World.cfg.dieSubStateSetting.autoHurtTime
end

function Player:startAutoHurtSelf()
  self:setValue("autoHurtSelf", true)
  self:playDieSubStateAction(Define.DIE_SUB_STATE.AutoHurt)
end

function Player:addDieHurtHp(hp)
  if hp < 0 and self.dieSubState ~= nil then
    hp = -hp
    if self.dieSubState and not self:getValue("autoHurtSelf") then
      self.totalHurtSelfHp = self.totalHurtSelfHp + hp
      if self.totalHurtSelfHp >= World.cfg.dieSubStateSetting.totalHurtSelfHp then
        self:startAutoHurtSelf()
      end
    end
  end
end

function Player:clearDieSubState()
  if self.myRideTarget and self.myRideTarget:isValid() then
    self:rideOn(nil)
    self.myRideTarget.myPassengers = nil
    self.myRideTarget:sendPacket({
      pid = "onUpdateCarryBtn",
      param = {
        userId = self.platformUserId,
        triggerType = "Exit"
      }
    })
    self.myRideTarget:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
  end
  self:exitOnGround()
  self.myRideTarget = nil
  self.dieSubState = nil
  self.carrier = nil
  self:setValue("autoHurtSelf", false)
  self.dieSubStateInvincible = false
  if self.dieSubStateUpdateTimer then
    self.dieSubStateUpdateTimer()
    self.dieSubStateUpdateTimer = nil
  end
end

local healthCfg = World.cfg.playerAttrs.healthCfg

function Player:getHealthRegenTime()
  if self.dieSubState == nil then
    return healthCfg.normal.healthRegenTime
  else
    return healthCfg.onGround.healthRegenTime
  end
end

function Player:getHealthRegenRate()
  if self.dieSubState == nil then
    return healthCfg.normal.healthRegenRate
  else
    return healthCfg.onGround.healthRegenRate
  end
end

function Player:checkReLife()
  local playerHp = self:getCurHp()
  if playerHp > World.cfg.dieSubStateSetting.reLifeHp * self:getMaxHp() then
    self:clearDieSubState()
    self:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
  end
end

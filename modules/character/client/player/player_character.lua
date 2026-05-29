local Player = _ENV.Player

function Player:RechargeFull()
  if not self.rechargeFull then
    self.rechargeFull = true
    local chargeAction = self.weapon:getChargeAction()
    self:sendPacket({
      pid = "sendRechargeFull",
      chargeAction = chargeAction
    })
  end
end

function Player:resetRecharge()
  self:sendPacket({
    pid = "resetRecharge"
  })
  self:changeState(Define.CHARACTER_STATE_TYPE.SKILL)
end

function Player:getIsRechargeFull()
  return self.rechargeFull
end

function Player:doHurtMoveSpeed()
  self.isHurtCutSpeed = true
  Me.speedState = Define.SPEED_STATE.NONE
  World.LightTimer("self.isHurtCutSpeed", World.cfg.hurtCutSpeed.time, function()
    self.isHurtCutSpeed = false
    Me.speedState = Define.SPEED_STATE.NONE
  end)
end

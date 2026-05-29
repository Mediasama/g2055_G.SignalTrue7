local playerAttrsSetting = World.cfg.playerAttrs
local ValueDef = T(Entity, "ValueDef")
ValueDef.max_hp = {
  false,
  false,
  true,
  true,
  playerAttrsSetting.roleHp,
  true
}
ValueDef.cur_hp = {
  false,
  false,
  true,
  true,
  playerAttrsSetting.roleHp,
  true
}
local Entity = _ENV.Entity

function Entity:getMaxHp()
  self.max_hp = self.max_hp or self:getValue("max_hp")
  return self.max_hp
end

function Entity:setMaxHp(maxHp)
  self.max_hp = maxHp
  self:setValue("max_hp", maxHp)
  self:setValue("cur_hp", maxHp)
end

function Entity:getCurHp()
  return self:getValue("cur_hp")
end

function Entity:setCurHp(hp)
  self:setValue("cur_hp", hp)
end

function Entity:getIsDead()
  return self.beDead
end

function Entity:setIsDead(b)
  self.beDead = b
end

function Entity:changeHp(hp)
  local oldHp = self:getCurHp()
  local curHp = oldHp + hp
  if self.isPlayer then
    self:addDieHurtHp(hp)
  end
  if curHp <= 0 then
    curHp = 0
    self:setCurHp(curHp)
    if self.isPlayer then
      Lib.emitEvent(Event.EVENT_PLAYER_ENTER_DYING, self.objID, self)
      local BastionManager = require("server.bastion_manager")
      BastionManager.Instance():responsePlayerDie(self.platformUserId)
      local packet = {
        pid = "S2C_NotifyPlayDie",
        userId = self.platformUserId,
        objID = self.objID
      }
      WorldServer.BroadcastPacket(packet)
      self:onEnterDieState()
      curHp = self:getCurHp()
    else
      self:setIsDead(true)
    end
  else
    self:setCurHp(curHp)
  end
  if not self.lostHPBeginTime then
    self.lostHPBeginTime = World.CurWorld:getTickCount()
  end
  if 0 < curHp then
    self.changeHpTime = World.CurWorld:getTickCount() * 0.05
    self.startHealth = false
    self.healthDownTime = 0
    if self.isPlayer and not self.logicTimer then
      self.logicTimer = World.LightTimer("hp behavior", 1, function()
        if self:isValid() and self.onHPUpdate then
          self:onHPUpdate(0.05)
          return true
        else
          return false
        end
      end)
    end
    if self.startHealthTimer then
      self.startHealthTimer()
      self.startHealthTimer = nil
    end
  end
  return curHp - oldHp
end

function Entity:onDie()
  if self._isDoDie then
    return
  end
  self._isDoDie = true
  if self.isPlayer then
    Lib.emitEvent(Event.EVENT_PLAYER_DEATH, self.objID, self)
    self:changeState(Define.CHARACTER_STATE_TYPE.DIE)
  else
    Lib.emitEvent(Event.EVENT_ENTITY_DEATH, self.objID, self)
  end
  self.startHealth = false
  if self.startHealthTimer then
    self.startHealthTimer()
    self.startHealthTimer = nil
  end
  if self.logicTimer then
    self.logicTimer()
    self.logicTimer = nil
  end
end

function Entity:getLostHPTime()
  return (World.CurWorld:getTickCount() - self.lostHPBeginTime) * 0.05
end

function Entity:revive()
  if not self:isValid() then
    return
  end
  self:setCurHp(self.max_hp)
  self:setIsDead(false)
  if self.battleField then
    self.battleField:onRevive(self)
  end
  self:syncPlayerData()
  self:setActionIdle("idle")
  self:setActionRun("run")
  self._isDoDie = false
  self.lostHPBeginTime = nil
  self.isNearDoor = false
  self:clearRecordHurtData()
  self.isWuDi = true
  World.LightTimer("hp behavior", 20, function()
    self.isWuDi = false
  end)
end

function Entity:isInvincible()
  return not self.isPlayer or self:isDriving() or self.isWuDi or self:isDieSubStateInvincible()
end

function Entity:onHPUpdate(dt)
  if self:getIsDead() or not self:isValid() then
    return
  end
  if self.isMoving and not self:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) then
    self.healthDownTime = 0
    if self.startHealthTimer then
      self.startHealthTimer()
      self.startHealthTimer = nil
      self.startHealth = false
    end
    return
  end
  self.healthDownTime = self.healthDownTime + dt
  if self.healthDownTime >= self:getHealthRegenTime() and not self.startHealth then
    if self:getCurHp() ~= self.max_hp then
      self.startHealth = true
    end
    self.healthDownTime = 0
  end
  if self.startHealth and not self.startHealthTimer then
    local time = self:getHealthRegenRate()[1] * 20
    local playSound = true
    self.startHealthTimer = World.LightTimer("hp ", time, function()
      self.startHealthTimer = nil
      if not self.getValue or not self:isValid() then
        return
      end
      if not self:enableAutoReduceHp() then
        return
      end
      self:onHealth(self:getHealthRegenRate())
      if playSound then
        self:playSoundOnClient("g2055_battle_breathHeal")
        playSound = false
      end
    end)
  end
end

function Entity:onHealth(conf)
  local oldHp = self:getCurHp()
  if oldHp == self.max_hp then
    self.startHealth = false
    self.lostHPBeginTime = nil
    self:clearRecordHurtData()
    if self.logicTimer then
      self.logicTimer()
      self.logicTimer = nil
    end
    return
  end
  local curHp = oldHp + conf[3]
  if curHp >= self.max_hp then
    curHp = self.max_hp
  end
  self:setCurHp(curHp)
end

function Entity:setVehicleMaxHp(maxHp)
  self.isVehicle = true
  self:setMaxHp(maxHp)
end

function Entity:recordHurtData(id, hurtValue, playerID)
  self.reportDataPlayerIDS = self.reportDataPlayerIDS or {}
  if not Lib.tableContain(self.reportDataPlayerIDS, playerID) then
    table.insert(self.reportDataPlayerIDS, playerID)
  end
  self.reportDataHurtValues = self.reportDataHurtValues or {}
  self.reportDataHurtValues[id] = self.reportDataHurtValues[id] and self.reportDataHurtValues[id] + hurtValue or hurtValue
end

function Entity:clearRecordHurtData()
  self.reportDataPlayerIDS = {}
  self.reportDataHurtValues = {}
end

function Entity:getRecordHurtData()
  local playerIDStr = ""
  for i, v in ipairs(self.reportDataPlayerIDS) do
    if playerIDStr ~= "" then
      playerIDStr = playerIDStr .. ","
    end
    playerIDStr = playerIDStr .. v
  end
  local hurtDataStr = ""
  for id, v in pairs(self.reportDataHurtValues) do
    if hurtDataStr ~= "" then
      hurtDataStr = hurtDataStr .. ";"
    end
    hurtDataStr = hurtDataStr .. id .. "," .. v
  end
  return playerIDStr, hurtDataStr
end

function Entity:resetOnHealth()
  self.changeHpTime = World.CurWorld:getTickCount() * 0.05
end

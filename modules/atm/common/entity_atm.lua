local ValueDef = T(Entity, "ValueDef")
ValueDef.ATMState = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.ATMCfgId = {
  false,
  false,
  false,
  false,
  -1,
  false
}
ValueDef.ATMCurMoney = {
  false,
  false,
  false,
  false,
  -1,
  false
}
ValueDef.ATMDropStamp = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.ATMHurtStamp = {
  false,
  false,
  true,
  true,
  0,
  false
}
local Entity = _ENV.Entity

function Entity:setATMState(state)
  self:setValue("ATMState", state)
  if not World.isClient then
    if self:cfg().ATMType == Define.ATM_TYPE.ATM_NPC then
      local actionName = self:cfg().action.idle
      if state == Define.ATM_STATE.ST_DEAD then
        actionName = self:cfg().action.dead
      end
      self:playAMTAction(actionName)
    elseif self:cfg().ATMType == Define.ATM_TYPE.ATM then
      local actorName = self:cfg().actorName
      if state == Define.ATM_STATE.ST_DEAD then
        actorName = self:cfg().brokenActorName
      end
      self:changeActor(actorName)
    end
  end
end

function Entity:playATMHurtAction()
  if self:cfg().ATMType == Define.ATM_TYPE.ATM then
    self:sendPacketToTracking({
      pid = "playATMHurtActionS2C",
      atmOjbId = self.objID
    }, true)
  end
end

function Entity:getATMState()
  return self:getValue("ATMState")
end

function Entity:getATMCfgId()
  return self:getValue("ATMCfgId")
end

function Entity:setATMCfgId(id)
  return self:setValue("ATMCfgId", id)
end

function Entity:getATMCurMoney()
  return self:getValue("ATMCurMoney")
end

function Entity:setATMCurMoney(num)
  return self:setValue("ATMCurMoney", math.max(0, math.floor(num)))
end

function Entity:getATMDropStamp()
  return self:getValue("ATMDropStamp")
end

function Entity:setATMDropStamp(stamp)
  return self:setValue("ATMDropStamp", math.floor(stamp))
end

function Entity:getATMHurtStamp()
  return self:getValue("ATMHurtStamp")
end

function Entity:setATMHurtStamp(stamp)
  return self:setValue("ATMHurtStamp", stamp)
end

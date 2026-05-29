local ValueDef = T(Entity, "ValueDef")
local Entity = _ENV.Entity
ValueDef.soundMoonCard = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.soundTimes = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.freeSoundFlag = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.freeSoundTimes = {
  false,
  false,
  true,
  false,
  0,
  true
}

function Entity:getSoundTimes()
  return self:getValue("soundTimes") or 0
end

function Entity:useSoundTimes()
  if self:getSoundMoonCardEnable() then
    return
  end
  self:setValue("soundTimes", self:getSoundTimes() - 1)
end

function Entity:getFreeSoundFlag()
  return self:getValue("freeSoundFlag") or 0
end

function Entity:setFreeSoundFlag(flag)
  self:setValue("freeSoundFlag", flag)
end

function Entity:updateFreeSoundFlag()
  if self:getFreeSoundFlag() == 0 then
    self:setFreeSoundFlag(1)
    if not self:getSoundMoonCardEnable() then
      self:initFreeSoundTimes()
    end
  end
end

function Entity:getFreeSoundTimes()
  return self:getValue("freeSoundTimes") or 0
end

function Entity:useFreeSoundTimes()
  self:setValue("freeSoundTimes", self:getFreeSoundTimes() - 1)
end

function Entity:resetFreeSoundTimes()
  self:setValue("freeSoundTimes", 0)
end

function Entity:initFreeSoundTimes()
  self:setValue("freeSoundTimes", World.cfg.chatSetting.freeSoundPerDay)
end

function Entity:getSoundMoonCardMac()
  return self:getValue("soundMoonCard") or 0
end

function Entity:setSoundMoonCardMac(value)
  self:setValue("soundMoonCard", value)
end

function Entity:getSoundMoonCardEnable()
  return self:getSoundMoonCardMac() > 0
end

function Entity:getCanSendSound()
  return self:getSoundTimes() > 0 or self:getSoundMoonCardEnable() or 0 < self:getFreeSoundTimes()
end

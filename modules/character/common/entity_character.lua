local ValueDef = T(Entity, "ValueDef")
ValueDef.action_idle = {
  false,
  false,
  true,
  true,
  "",
  true
}
ValueDef.action_run = {
  false,
  false,
  true,
  true,
  "",
  true
}
ValueDef.character_state = {
  false,
  true,
  true,
  true,
  "",
  false
}
ValueDef.defaultSkin = {
  false,
  false,
  false,
  false,
  nil,
  false
}
local Entity = _ENV.Entity

function Entity:getActionIdle()
  return self:getValue("action_idle")
end

function Entity:setActionIdle(name)
  self:setValue("action_idle", name)
end

function Entity:getActionRun()
  return self:getValue("action_run")
end

function Entity:setActionRun(name)
  self:setValue("action_run", name)
end

function Entity:getCharacterState()
  return self:getValue("character_state")
end

function Entity:setCharacterState(state)
  self:setValue("character_state", state)
end

function Entity:getDefaultSkin()
  return self:getValue("defaultSkin")
end

function Entity:setDefaultSkin(skins)
  if not skins or not next(skins) then
    return
  end
  self:setValue("defaultSkin", skins)
end

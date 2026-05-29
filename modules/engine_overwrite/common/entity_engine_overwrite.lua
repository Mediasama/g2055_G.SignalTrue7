local ValueDef = T(Entity, "ValueDef")
ValueDef.lastLoginTime = {
  false,
  false,
  false,
  false,
  0,
  true
}

function Entity:getLastLoginTime()
  return self:getValue("lastLoginTime")
end

function Entity:updateLastLoginTime()
  self:setValue("lastLoginTime", os.time())
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

local ValueDef = T(Entity, "ValueDef")
ValueDef.guide_id = {
  false,
  false,
  true,
  false,
  100,
  true
}
ValueDef.open_guide = {
  false,
  false,
  true,
  false,
  0,
  true
}
local Entity = _ENV.Entity

function Entity:getGuideID()
  return self:getValue("guide_id")
end

function Entity:setGuideID(id)
  self:setValue("guide_id", id)
end

function Entity:isOpenGuide()
  if not World.cfg.openGuide then
    return false
  end
  return self:getValue("open_guide") == 1
end

function Entity:setOpenGuide()
  print("Entity:setOpenGuide()")
  self:setValue("open_guide", 1)
end

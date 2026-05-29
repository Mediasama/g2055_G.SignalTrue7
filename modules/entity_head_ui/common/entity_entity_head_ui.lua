local ValueDef = T(Entity, "ValueDef")
ValueDef.entityHeadUI = {
  false,
  false,
  true,
  true,
  {
    name = {visible = false, value = nil},
    progress = {
      visible = false,
      min = nil,
      max = nil,
      hideTime = nil
    },
    showSelf = false
  },
  false
}
local Entity = _ENV.Entity

function Entity:setHeadUIData(data)
  self:setValue("entityHeadUI", data)
end

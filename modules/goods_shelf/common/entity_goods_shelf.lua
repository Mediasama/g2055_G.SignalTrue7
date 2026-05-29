local ValueDef = T(Entity, "ValueDef")
ValueDef.goods_shelf = {
  false,
  false,
  true,
  true,
  {},
  false
}
local EntityGoodsShelf = Entity

function EntityGoodsShelf:getGoodShelfProperty()
  return self:getValue("goods_shelf") or {}
end

function EntityGoodsShelf:setGoodsShelfProperty(value)
  self:setValue("goods_shelf", value)
end

function EntityGoodsShelf:gsp_getID()
  local property = self:getGoodShelfProperty()
  return property.id or 0
end

function EntityGoodsShelf:gsp_setID(id)
  local property = self:getGoodShelfProperty()
  property.id = id
  self:setGoodsShelfProperty(property)
end

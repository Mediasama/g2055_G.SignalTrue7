local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_closet = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBastion = Entity

function EntityBastion:getBastionCloset()
  return self:getValue("bastion_closet") or {}
end

function EntityBastion:setBastionCloset(value)
  self:setValue("bastion_closet", value)
end

function EntityBastion:getBastionClothesDict()
  local closet = self:getBastionCloset()
  return closet.clothesDict or {}
end

function EntityBastion:setBastionClothesDict(dict)
  local closet = self:getBastionCloset()
  closet.clothesDict = dict
  self:setBastionCloset(closet)
end

function EntityBastion:getBastionClothesItem(id)
  local clothesDict = self:getBastionClothesDict()
  return clothesDict[id]
end

function EntityBastion:setBastionClothesItem(id, item)
  local clothesDict = self:getBastionClothesDict()
  clothesDict[id] = item
  self:setBastionClothesDict(clothesDict)
end

function EntityBastion:addBastionClothesItem(item)
  self:setBastionClothesItem(item.id, item)
end

function EntityBastion:deleteBastionClosetItem(id)
  self:setBastionClothesItem(id, nil)
end

function EntityBastion:getBastionClosetCreateTime()
  local closet = self:getBastionCloset()
  return closet.createTime or 0
end

function EntityBastion:setBastionClosetCreateTime(time)
  local closet = self:getBastionCloset()
  closet.createTime = time
  self:setBastionCloset(closet)
end

local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_garage = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBastion = Entity

function EntityBastion:getBastionGarage()
  return self:getValue("bastion_garage") or {}
end

function EntityBastion:setBastionGarage(value)
  self:setValue("bastion_garage", value)
end

function EntityBastion:getBastionCarDict()
  local garage = self:getBastionGarage()
  return garage.carDict or {}
end

function EntityBastion:setBastionCarDict(dict)
  local garage = self:getBastionGarage()
  garage.carDict = dict
  self:setBastionGarage(garage)
end

function EntityBastion:clearBastionCarDict()
  self:setBastionCarDict({})
end

function EntityBastion:getBastionCarItem(index)
  local carDict = self:getBastionCarDict()
  return carDict[index]
end

function EntityBastion:setBastionCarItem(index, item)
  local carDict = self:getBastionCarDict()
  carDict[index] = item
  self:setBastionCarDict(carDict)
end

function EntityBastion:deleteBastionCarItem(index)
  self:setBastionCarItem(index, nil)
end

function EntityBastion:getBastionGarageLevel()
  local closet = self:getBastionGarage()
  return closet.level or 0
end

function EntityBastion:setBastionGarageLevel(level)
  local closet = self:getBastionGarage()
  closet.level = level
  self:setBastionGarage(closet)
end

function EntityBastion:getBastionGarageCreateTime()
  local closet = self:getBastionGarage()
  return closet.createTime or 0
end

function EntityBastion:setBastionGarageCreateTime(time)
  local closet = self:getBastionGarage()
  closet.createTime = time
  self:setBastionGarage(closet)
end

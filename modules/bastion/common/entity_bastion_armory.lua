local uuid = require("common.uuid")
local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_armory = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBastion = Entity

function EntityBastion:getBastionArmory()
  return self:getValue("bastion_armory") or {}
end

function EntityBastion:setBastionArmory(value)
  self:setValue("bastion_armory", value)
end

function EntityBastion:getBastionArmoryDict()
  local armory = self:getBastionArmory()
  return armory.armoryDict or {}
end

function EntityBastion:setBastionArmoryDict(dict)
  local armory = self:getBastionArmory()
  armory.armoryDict = dict
  self:setBastionArmory(armory)
end

function EntityBastion:getBastionArmoryTotalCount()
  local count = 0
  local armoryDict = self:getBastionArmoryDict()
  for i, v in pairs(armoryDict) do
    count = count + 1
  end
  return count
end

function EntityBastion:getBastionArmoryItemCount(id)
  local count = 0
  local armoryDict = self:getBastionArmoryDict()
  for i, item in pairs(armoryDict) do
    if item.id == id then
      count = count + 1
    end
  end
  return count
end

function EntityBastion:getBastionArmoryItem(slotId)
  local armoryDict = self:getBastionArmoryDict()
  return armoryDict[slotId]
end

function EntityBastion:setBastionArmoryItem(slotId, item)
  local armoryDict = self:getBastionArmoryDict()
  armoryDict[slotId] = item
  self:setBastionArmoryDict(armoryDict)
end

function EntityBastion:addBastionArmoryItem(item)
  local slotId = uuid()
  item.slotId = slotId
  self:setBastionArmoryItem(item.slotId, item)
end

function EntityBastion:deleteBastionArmoryItem(slotId)
  self:setBastionArmoryItem(slotId, nil)
end

function EntityBastion:getBastionArmoryLevel()
  local closet = self:getBastionArmory()
  return closet.level or 0
end

function EntityBastion:setBastionArmoryLevel(level)
  local closet = self:getBastionArmory()
  closet.level = level
  self:setBastionArmory(closet)
end

function EntityBastion:getBastionArmoryCreateTime()
  local armory = self:getBastionArmory()
  return armory.createTime or 0
end

function EntityBastion:setBastionArmoryCreateTime(time)
  local armory = self:getBastionArmory()
  armory.createTime = time
  self:setBastionArmory(armory)
end

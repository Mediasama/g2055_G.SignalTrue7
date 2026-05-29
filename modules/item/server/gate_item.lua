local ItemServer = T(Lib, "ItemServer")
local WeaponConfig = require("common.config.weapon_config")
local GoodsBaseConfig = T(Config, "GoodsBaseConfig")
local insCount = 0

local function createGUID()
  local s = 100000
  insCount = (insCount + 1) % s
  local time = (os.time() - 1647870510) * s + insCount
  return tonumber(time)
end

function ItemServer:export_createInventoryItem(itemID, count)
  itemID = tonumber(itemID)
  local config = GoodsBaseConfig:getCfgById(itemID)
  local itemData = {}
  itemData.itemID = itemID
  itemData.count = count or 1
  itemData.bulletCount = -1
  itemData.guid = createGUID()
  if config and config.firstType == Define.InventoryType.Weapon then
    itemData.isMelee = config.secondType == 1
    local conf = WeaponConfig:getCfgById(itemID)
    itemData.bulletCount = conf.bulletCount
  end
  return itemData
end

function ItemServer:export_addHadBagItem(entity, itemID, source)
  local itemData = self:export_createInventoryItem(itemID)
  local index
  local inventory = entity:getInventory(Define.InventoryType.HandBag)
  for i = 1, 3 do
    local data = inventory[i]
    if not data then
      index = i
      break
    end
  end
  if not index then
    index = 1
    if entity.handSelectIndex and entity.handSelectIndex > 0 then
      index = entity.handSelectIndex
    end
  end
  entity:replaceHandBag(itemData, index, true, source)
end

function ItemServer:export_hadBagIsFull(entity)
  local isFull = true
  local inventory = entity:getInventory(Define.InventoryType.HandBag)
  for i = 1, 3 do
    local data = inventory[i]
    if not data then
      isFull = false
      break
    end
  end
  return isFull
end

function ItemServer:export_createWeaponItemData(itemID, bulletCount)
  itemID = tonumber(itemID)
  local itemData = {}
  itemData.itemID = itemID
  itemData.count = 1
  itemData.bulletCount = bulletCount
  itemData.guid = createGUID()
  local config = GoodsBaseConfig:getCfgById(itemID)
  if config and config.firstType == Define.InventoryType.Weapon then
    itemData.isMelee = config.secondType == 1
    local conf = WeaponConfig:getCfgById(itemID)
    if not bulletCount then
      itemData.bulletCount = conf.bulletCount
    end
  end
  return itemData
end

return ItemServer

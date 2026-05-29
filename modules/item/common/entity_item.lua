local ItemServer = T(Lib, "ItemServer")
local Entity = _ENV.Entity
local playerBagCountSetting = World.cfg.inventory
local ValueDef = T(Entity, "ValueDef")
ValueDef.handBag = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.weaponBag = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.clothesBag = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.vehicleBag = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.costItemBag = {
  false,
  false,
  true,
  false,
  {},
  true
}

function Entity:getCostItemByItemID(itemID)
  local itemMap = self:getValue("costItemBag")
  return itemMap[itemID]
end

function Entity:getCostItemCountByItemID(itemID)
  local costItemData = self:getCostItemByItemID(itemID)
  if not costItemData then
    return 0
  end
  return costItemData.count or 0
end

function Entity:changeCostItemCount(itemID, count)
  count = count or 1
  local itemMap = self:getValue("costItemBag")
  local costItemData = itemMap[itemID]
  if not costItemData then
    costItemData = {}
    costItemData.itemID = itemID
    costItemData.count = 0
    itemMap[itemID] = costItemData
  end
  costItemData.count = costItemData.count + count
  if costItemData.count < 0 then
    costItemData.count = 0
  end
  self:setValue("costItemBag", itemMap)
  return true
end

local CountArray = {
  playerBagCountSetting.weaponBag,
  playerBagCountSetting.clothesBag,
  playerBagCountSetting.vehicleBag,
  playerBagCountSetting.handBag
}

function Entity:getBagMaxCount(inventoryType)
  print("inventoryType", inventoryType)
  return CountArray[inventoryType]
end

function Entity:getInventory(type)
  if type == Define.InventoryType.HandBag then
    return self:getValue("handBag")
  end
  if type == Define.InventoryType.Weapon then
    return self:getValue("weaponBag")
  end
  if type == Define.InventoryType.Clothes then
    return self:getValue("clothesBag")
  end
  if type == Define.InventoryType.Vehicle then
    return self:getValue("vehicleBag")
  end
  print("error: Entity:getInventory(type) not type=", type)
end

function Entity:saveInventory(type, inventory)
  if type == Define.InventoryType.HandBag then
    self:setValue("handBag", inventory)
    return true
  end
  if type == Define.InventoryType.Weapon then
    self:setValue("weaponBag", inventory)
    return true
  end
  if type == Define.InventoryType.Clothes then
    self:setValue("clothesBag", inventory)
    return true
  end
  if type == Define.InventoryType.Vehicle then
    self:setValue("vehicleBag", inventory)
    return true
  end
  return false
end

function Entity:isInventoryFull(inventoryType)
  local inventory = self:getInventory(inventoryType)
  if not inventory then
    return true
  end
  if self:getBagMaxCount(inventoryType) >= #inventory then
    return true
  end
end

function Entity:checkAddItemEnable(itemData, inventoryType)
  local itemID, guid = itemData.itemID, itemData.guid
  local inventory = self:getInventory(inventoryType)
  if not inventory then
    return Define.AddItemResult.Error
  end
  if self:getBagMaxCount(inventoryType) <= #inventory then
    print("\229\174\185\233\135\143\229\183\178\230\187\161\239\188\129\239\188\129\239\188\129", inventoryType, itemID)
    return Define.AddItemResult.Full
  end
  for i, v in pairs(inventory) do
    if v.guid == guid and v.itemID == itemID then
      return Define.AddItemResult.Repeat
    end
  end
  return Define.AddItemResult.Success
end

function Entity:addItemToInventory(itemData, inventoryType)
  local result = self:checkAddItemEnable(itemData, inventoryType)
  if result == Define.AddItemResult.Success then
    local inventory = self:getInventory(inventoryType)
    table.insert(inventory, itemData)
    if not self:saveInventory(inventoryType, inventory) then
      result = Define.AddItemResult.Error
    end
  end
  return result
end

function Entity:replaceInventoryItem(itemData, inventoryType, index)
  local result = Define.AddItemResult.Success
  local data
  local inventory = self:getInventory(inventoryType)
  data = inventory[index]
  inventory[index] = itemData
  if not self:saveInventory(inventoryType, inventory) then
    result = Define.AddItemResult.Error
  end
  return result, data
end

function Entity:getItemDataByIndex(inventoryType, index)
  local inventory = self:getInventory(inventoryType)
  return inventory and inventory[index]
end

function Entity:getItemDataByGUID(inventoryType, guid)
  local inventory = self:getInventory(inventoryType)
  for i, v in pairs(inventory or {}) do
    if v.guid == guid then
      return v
    end
  end
end

function Entity:getItemDataByItemID(inventoryType, itemID)
  local inventory = self:getInventory(inventoryType)
  for i, v in pairs(inventory or {}) do
    if v.itemID == itemID then
      return v
    end
  end
end

function Entity:getItemCountByItemID(inventoryType, itemID)
  local count = 0
  local inventory = self:getInventory(inventoryType)
  for i, v in pairs(inventory or {}) do
    if v.itemID == itemID then
      count = count + 1
    end
  end
  return count
end

function Entity:decreaseInventoryItem(inventoryType, itemID, num)
end

function Entity:delInventoryItem(inventoryType, itemData)
  local inventory = self:getInventory(inventoryType)
  local index = self:getItemDataByGUID(inventoryType, itemData.guid)
  inventory[index] = nil
  return self:saveInventory(inventoryType, inventory)
end

function Entity:delInventoryItemByIndex(inventoryType, index)
  local inventory = self:getInventory(inventoryType)
  inventory[index] = nil
  return self:saveInventory(inventoryType, inventory)
end

function Entity:clearHandBagAndMoney(dropList, goldCount, posList)
  local itemCountMap = {}
  for i, v in ipairs(dropList) do
    itemCountMap[v.itemID] = itemCountMap[v.itemID] and itemCountMap[v.itemID] + 1 or 1
    GameAnalytics.ItemFlow(self, Define.ReportItemType.Weapon, v.itemID, 1, false, Define.ReportCostAccessType.DieDrop, "die drop", v.guid)
  end
  for id, count in pairs(itemCountMap) do
    local d = {}
    d.access_type_drop = Define.ReportCostAccessType.DieDrop
    d.item_type = Define.ReportItemType.Weapon
    d.item_id = id
    d.drop_amount = count
    d.current_num = 0
    self:reportItemCost(d)
  end
  local inventory = self:getInventory(Define.InventoryType.HandBag)
  for i, v in ipairs(posList) do
    inventory[v] = nil
  end
  self:saveInventory(Define.InventoryType.HandBag, inventory)
  if 0 < goldCount then
    print("goldCount===", goldCount, type(goldCount))
    self:payCurrencyById(Define.CURRENCY_ID.gold, goldCount, Define.CurrencyReason.Die)
  end
  self:resetDefaultWeapon()
end

function Entity:getVehicleCountByItemID(itemID)
  local vehicleItemData = self:getValue("vehicleBag")[itemID]
  if not vehicleItemData then
    return 0
  end
  return vehicleItemData.count or 0
end

function Entity:changeVehicleCount(itemID, count)
  count = count or 1
  local itemMap = self:getValue("vehicleBag")
  local vehicleItemData = itemMap[itemID]
  if not vehicleItemData then
    vehicleItemData = {}
    vehicleItemData.itemID = itemID
    vehicleItemData.count = 0
    itemMap[itemID] = vehicleItemData
  end
  vehicleItemData.count = vehicleItemData.count + count
  if vehicleItemData.count < 0 then
    vehicleItemData.count = 0
  end
  self:setValue("vehicleBag", itemMap)
  return true
end

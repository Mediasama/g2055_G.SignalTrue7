local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function Entity:replaceHandBag(itemData, index, isDrop, source)
  if not self.handSelectIndex then
    self.handSelectIndex = 0
  end
  if self:getItemDataByIndex(Define.InventoryType.HandBag, index) and self.handSelectIndex > 0 then
    self:changeWeapon(itemData.itemID)
  end
  local result, data = self:replaceInventoryItem(itemData, Define.InventoryType.HandBag, index)
  if result == Define.AddItemResult.Success then
    if source then
      local d = {}
      d.access_type = source
      d.item_type = Define.ReportItemType.Weapon
      d.item_id = itemData.itemID
      d.gain_amount = 1
      d.current_num = self:getHandBagWeaponCount(itemData.itemID)
      self:reportItemGet(d)
      GameAnalytics.ItemFlow(self, Define.ReportItemType.Weapon, itemData.itemID, 1, true, source, "get drop", itemData.guid)
    end
    if isDrop and data and self.battleField then
      local clonePosition = Vector3.new(0, 0, 1.5)
      local rotation = Vector3.new(-self:getRotationPitch(), -self:getRotationYaw(), -self:getRotationRoll())
      Lib.rotate(clonePosition, rotation)
      local myPos = self:getPosition()
      local pos = myPos + clonePosition
      pos.y = myPos.y + 1
      self.battleField:createDrop(pos, data.itemID, data.count, data, nil, Define.ItemDataDropState.Discard)
      if source then
        local d = {}
        d.access_type_drop = Define.ReportCostAccessType.Discard
        d.item_type = Define.ReportItemType.Weapon
        d.item_id = data.itemID
        d.drop_amount = 1
        d.current_num = self:getHandBagWeaponCount(data.itemID)
        GameAnalytics.ItemFlow(self, Define.ReportItemType.Weapon, data.itemID, 1, false, Define.ReportCostAccessType.Discard, "drop ground", data.guid)
        self:reportItemCost(d)
      end
    end
  end
  return data
end

function Entity:deleteHandBag(index)
  self:delInventoryItemByIndex(Define.InventoryType.HandBag, index)
end

function Entity:getHandBagByIndex(index)
  return self:getItemDataByIndex(Define.InventoryType.HandBag, index)
end

function Entity:getInsertHandBagIndex(selectIndex)
  local index
  local inventory = self:getInventory(Define.InventoryType.HandBag)
  for i = 1, World.cfg.inventory.handBag do
    local data = inventory[i]
    if not data then
      index = i
      break
    end
  end
  index = index or selectIndex or 1
  return index
end

function Entity:reportItemGet(data)
  self:evt_reportEvent("item_gain", data, true)
end

function Entity:reportItemCost(data)
  self:evt_reportEvent("item_drop", data, true)
end

function Entity:getHandBagWeaponCount(itemID)
  local count = 0
  local inventory = self:getInventory(Define.InventoryType.HandBag)
  for i = 1, World.cfg.inventory.handBag do
    local data = inventory[i]
    if data and data.itemID == itemID then
      count = count + 1
    end
  end
  return count
end

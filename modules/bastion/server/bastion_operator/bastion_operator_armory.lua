local ItemServer = T(Lib, "ItemServer")
local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorArmory = Lib.class("BastionOperatorArmory", BastionOperatorBase)

function BastionOperatorArmory:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.Armory
end

function BastionOperatorArmory:operate(param)
  local result = {}
  local ownerId = param.ownerId
  local owner = Game.GetPlayerByUserId(ownerId)
  if not owner or not owner:isValid() then
    result.status = Define.Bastion.Facility.OperateErrorCode.InvalidOwner
    result.msg = "InvalidOwner userId:" .. (ownerId or "unknown")
    return result
  end
  local operatorId = param.operatorId
  local operator = Game.GetPlayerByUserId(operatorId)
  if not operator or not operator:isValid() then
    result.status = Define.Bastion.Facility.OperateErrorCode.InvalidOperator
    result.msg = "InvalidOperator userId:" .. (operatorId or "unknown")
    return result
  end
  local manner = param.manner
  if manner == Define.Bastion.Facility.OperateType.Query then
    return self:query(param)
  elseif manner == Define.Bastion.Facility.OperateType.Deposit then
    return self:deposit(param)
  elseif manner == Define.Bastion.Facility.OperateType.Fetch then
    return self:fetch(param)
  elseif manner == Define.Bastion.Facility.OperateType.Steal then
    return self:steal(param)
  elseif manner == Define.Bastion.Facility.OperateType.Buy then
    return self:buy(param)
  else
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.UnknownManner
    result.msg = "unknown manner:" .. (manner or "unknown")
    return result
  end
end

function BastionOperatorArmory:buy(param)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local level = operator:getBastionArmoryLevel()
  if 0 < level then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.buy.error.had.unlock"
    return result
  end
  local config = World.cfg.bastionSetting or {}
  local armory = config.armory or {}
  local unlockPrice = armory.unlockPrice or 100
  local cash = operator:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if unlockPrice > cash then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.buy.error.no.enough.money"
    return result
  end
  operator:payCurrencyById(Define.Bastion.Currency.Type.Gold, unlockPrice, Define.CurrencyReason.Armory)
  operator:setBastionArmoryLevel(1)
  local bastion = operator:getBastion()
  if bastion then
    bastion:reloadFacility()
    local armory = bastion:getFacility(Define.Bastion.Facility.Type.Armory)
    if armory then
      local trigger = armory.trigger
      if trigger and trigger:isValid() then
        operator:sendPacketToTracking({
          pid = "S2C_UpdateArmoryEffect",
          objID = trigger.objID
        }, true)
      end
    end
  end
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Armory.Buy)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(operator)
  return result
end

function BastionOperatorArmory:query(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  result.data.handbagSelectIndex = self:getHandBagSelectIndex(operator)
  return result
end

function BastionOperatorArmory:deposit(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local requestData = param.requestData
  local armorySlotID = requestData.armorySlotID or 0
  local handBagSlotID = requestData.handBagSlotID
  if not handBagSlotID then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.deposit.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local handbagItem = operator:getHandBagByIndex(handBagSlotID)
  if not handbagItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.deposit.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local config = World.cfg.bastionSetting or {}
  local armory = config.armory or {}
  local maxCount = armory.maxWeapons or 100
  local existCount = owner:getBastionArmoryTotalCount()
  if maxCount <= existCount then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.deposit.exceed.maximum"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local item = {
    id = handbagItem.itemID,
    bulletCount = handbagItem.bulletCount
  }
  operator:deleteHandBag(handBagSlotID)
  operator:bst_ReportLoseItem(Define.EventTracking.Item.Lose.Deposit, Define.EventTracking.Item.Type.Weapon, item.id, 1, self:getHandBagItemCount(operator, item.id))
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Weapon, item.id, 1, false, Define.ItemFlowReason.Deposit)
  owner:addBastionArmoryItem(item)
  owner:bst_ReportOperateFacility(Define.EventTracking.Facility.Armory.Deposit)
  local armoryItem = owner:getBastionArmoryItem(armorySlotID)
  if armoryItem then
    local itemData = ItemServer:export_createWeaponItemData(armoryItem.id, armoryItem.bulletCount)
    operator:replaceHandBag(itemData, handBagSlotID, false)
    owner:deleteBastionArmoryItem(armorySlotID)
    owner:bst_ReportOperateFacility(Define.EventTracking.Facility.Armory.Fetch)
  end
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  return result
end

function BastionOperatorArmory:fetch(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local requestData = param.requestData
  local armorySlotID = requestData.armorySlotID or 0
  local handBagSlotID = requestData.handBagSlotID or self:getHandBagDefaultSlotID(operator)
  handBagSlotID = operator:getInsertHandBagIndex(handBagSlotID)
  local armoryItem = owner:getBastionArmoryItem(armorySlotID)
  if not armoryItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.fetch.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local fetchItem = Lib.copy(armoryItem)
  local handbagItem = operator:getHandBagByIndex(handBagSlotID)
  if handbagItem then
    local item = {
      id = handbagItem.itemID,
      bulletCount = handbagItem.bulletCount
    }
    owner:addBastionArmoryItem(item)
    owner:bst_ReportOperateFacility(Define.EventTracking.Facility.Armory.Deposit)
  end
  owner:deleteBastionArmoryItem(armorySlotID)
  owner:bst_ReportOperateFacility(Define.EventTracking.Facility.Armory.Fetch)
  local itemData = ItemServer:export_createWeaponItemData(fetchItem.id, fetchItem.bulletCount)
  operator:replaceHandBag(itemData, handBagSlotID, false)
  operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Fetch, Define.EventTracking.Item.Type.Weapon, fetchItem.id, 1, self:getHandBagItemCount(operator, fetchItem.id))
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Weapon, fetchItem.id, 1, true, Define.ItemFlowReason.Fetch)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  return result
end

function BastionOperatorArmory:steal(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local requestData = param.requestData
  local armorySlotID = requestData.armorySlotID or 0
  local handBagSlotID = requestData.handBagSlotID or self:getHandBagDefaultSlotID(operator)
  handBagSlotID = operator:getInsertHandBagIndex(handBagSlotID)
  local armoryItem = owner:getBastionArmoryItem(armorySlotID)
  if not armoryItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.armory.steal.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local fetchItem = Lib.copy(armoryItem)
  owner:deleteBastionArmoryItem(armorySlotID)
  owner:bst_ReportLoseItem(Define.EventTracking.Item.Lose.Steal, Define.EventTracking.Item.Type.Weapon, armoryItem.id, 1, self:getHandBagItemCount(owner, armoryItem.id))
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Weapon, armoryItem.id, 1, false, Define.ItemFlowReason.Steal)
  local itemData = ItemServer:export_createWeaponItemData(fetchItem.id, fetchItem.bulletCount)
  operator:replaceHandBag(itemData, handBagSlotID, true)
  operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Steal, Define.EventTracking.Item.Type.Weapon, fetchItem.id, 1, self:getHandBagItemCount(operator, fetchItem.id))
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Weapon, fetchItem.id, 1, true, Define.ItemFlowReason.Steal)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  return result
end

function BastionOperatorArmory:getHandBagDefaultSlotID(player)
  local index = 1
  local inventory = player:getInventory(Define.InventoryType.HandBag)
  for i = 1, World.cfg.inventory.handBag do
    local data = inventory[i]
    if not data then
      index = i
      break
    end
  end
  return index
end

function BastionOperatorArmory:getHandBagSelectIndex(player)
  local selectIndex = 1
  if player.handSelectIndex and player.handSelectIndex > 0 then
    selectIndex = player.handSelectIndex
  end
  return selectIndex
end

function BastionOperatorArmory:getHandBagItems(player)
  local maxCount = World.cfg.inventory.handBag
  local dict = {}
  for i = 1, maxCount do
    local data = {}
    data.slotId = i
    data.id = -1
    data.bulletCount = -1
    dict[i] = data
  end
  local items = player:getInventory(Define.InventoryType.HandBag)
  for index, item in pairs(items) do
    dict[index].id = item.itemID
    dict[index].bulletCount = item.bulletCount
  end
  return dict
end

function BastionOperatorArmory:getHandBagItemCount(player, id)
  return player:getItemCountByItemID(Define.InventoryType.HandBag, id)
end

function BastionOperatorArmory:getArmoryItems(player)
  return player:getBastionArmoryDict()
end

function BastionOperatorArmory:getResponseData(owner, operator)
  local data = {}
  if not owner or not owner:isValid() then
    return data
  end
  if not operator or not operator:isValid() then
    return data
  end
  data.handbag = self:getHandBagItems(operator)
  data.armory = self:getArmoryItems(owner)
  data.level = owner:getBastionArmoryLevel()
  return data
end

return BastionOperatorArmory

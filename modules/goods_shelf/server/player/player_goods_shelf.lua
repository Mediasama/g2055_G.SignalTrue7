local ItemServer = T(Lib, "ItemServer")
local ClothesConfig = T(Config, "ClothesConfig")
local WeaponConfig = require("common.config.weapon_config")
local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
local GoodsBaseConfig = T(Config, "GoodsBaseConfig")
local BlackMarketGoodsConfig = T(Config, "BlackMarketGoodsConfig")
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local shelfTypeToAreaTypeDict = {}
shelfTypeToAreaTypeDict[Define.GoodsShelf.Type.Weapons] = Define.EventTracking.Area.Shop.Weapon
shelfTypeToAreaTypeDict[Define.GoodsShelf.Type.Clothes] = Define.EventTracking.Area.Shop.Clothes
shelfTypeToAreaTypeDict[Define.GoodsShelf.Type.Cars] = Define.EventTracking.Area.Shop.Car
shelfTypeToAreaTypeDict[Define.GoodsShelf.Type.BlackMarket] = Define.EventTracking.Area.Shop.BlackMarket
shelfTypeToAreaTypeDict[Define.GoodsShelf.Type.Bullet] = Define.EventTracking.Area.Shop.Bullet
local PlayerGoodsShelfServer = Player

function PlayerGoodsShelfServer:S2C_TriggerGoodsShelf(param)
  local packet = {
    pid = "S2C_TriggerGoodsShelf",
    operateType = param.operateType or Define.GoodsShelf.Type.None,
    id = param.id,
    objID = param.objID,
    triggerParam = param.triggerParam
  }
  self:sendPacket(packet)
  local goodsShelfID = param.id or 0
  local evtType = param.operateType or Define.GoodsShelf.Trigger.Type.None
  if evtType == Define.GoodsShelf.Trigger.Type.Open then
    self:evt_startStayArea()
    local config = GoodsShelfConfig:getCfgById(goodsShelfID)
    if not config then
      return
    end
    local areaType = shelfTypeToAreaTypeDict[config.type]
    if not areaType then
      return
    end
    local reportData = {area_type = areaType}
    self:evt_reportEvent(Define.EventTracking.Type.EnterArea, reportData)
  elseif evtType == Define.GoodsShelf.Trigger.Type.Close then
    local config = GoodsShelfConfig:getCfgById(goodsShelfID)
    if not config then
      return
    end
    local areaType = shelfTypeToAreaTypeDict[config.type]
    if not areaType then
      return
    end
    local reportData = {
      area_type = areaType,
      stay_time = self:evt_getStayAreaTime()
    }
    self:evt_reportEvent(Define.EventTracking.Type.ExitArea, reportData)
  end
end

function PlayerGoodsShelfServer:GoodsShelfDeliver(shelfId, type, id, fromBlackMarket)
  local gainType = Define.EventTracking.Item.Gain.Buy
  if fromBlackMarket then
    gainType = Define.EventTracking.Item.Gain.BlackMarket
  end
  if type == Define.GoodsShelf.Type.Clothes then
    local config = ClothesConfig:getCfgById(id)
    if not config then
      return
    end
    local wearItem = {id = id}
    self:addBastionClothesItem(wearItem)
    self:wearClothesItem(config.part, wearItem)
    self:bst_ReportGainItem(gainType, Define.EventTracking.Item.Type.Clothes, id, 1, 1)
    GameAnalytics.ItemFlow(self, Define.EventTracking.Item.Type.Clothes, id, 1, true, Define.ItemFlowReason.Buy)
  elseif type == Define.GoodsShelf.Type.Cars then
    self:buyCarFromShop(id, shelfId)
    self:bst_ReportGainItem(gainType, Define.EventTracking.Item.Type.Car, id, 1, 1)
    GameAnalytics.ItemFlow(self, Define.EventTracking.Item.Type.Car, id, 1, true, Define.ItemFlowReason.Buy)
  elseif type == Define.GoodsShelf.Type.Weapons then
    ItemServer:export_addHadBagItem(self, id, Define.ReportGetAccessType.Shop)
    self:bst_ReportGainItem(gainType, Define.EventTracking.Item.Type.Weapon, id, 1, self:getItemCountByItemID(Define.InventoryType.HandBag, id))
    GameAnalytics.ItemFlow(self, Define.EventTracking.Item.Type.Weapon, id, 1, true, Define.ItemFlowReason.Buy)
  elseif type == Define.GoodsShelf.Type.Item then
    self:changeCostItemCount(id, 1)
    self:bst_ReportGainItem(gainType, Define.EventTracking.Item.Type.Item, id, 1, self:getCostItemCountByItemID(id))
    GameAnalytics.ItemFlow(self, Define.EventTracking.Item.Type.Item, id, 1, true, Define.ItemFlowReason.Buy)
  end
end

function PlayerGoodsShelfServer:GoodsShelfBuyWeapon(param)
  if self:isDriving() then
    return
  end
  self:pam_stopMotion()
  local shelfID = param.shelfID
  local type = param.type or Define.GoodsShelf.Type.None
  local weaponId = param.id
  local config = WeaponConfig:getCfgById(weaponId)
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
  result.msg = "tips.no.money"
  if config then
    if self:getCurrencyById(config.currencyType) < config.price then
      result.msg = "tips.no.money"
    elseif self:payCurrencyById(config.currencyType, config.price, Define.CurrencyReason.Weapon) then
      self:GoodsShelfDeliver(shelfID, type, weaponId)
      result.status = Define.GoodsShelf.PurchaseErrorCode.Succeed
      result.msg = "ok"
    else
      result.msg = "tips.no.money"
    end
  end
  return result
end

function PlayerGoodsShelfServer:GoodsShelfBuyBullet(param)
  self:pam_stopMotion()
  local weaponId = param.id
  local config = WeaponConfig:getCfgById(weaponId)
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
  result.msg = "tips.no.money"
  if config then
    local currencyType = config.bulletCurrencyType
    local price = config.bulletPrice
    if price > self:getCurrencyById(currencyType) then
      result.msg = "tips.no.money"
    else
      local msg = self:buyBullet(weaponId)
      if msg == nil then
        result.status = Define.GoodsShelf.PurchaseErrorCode.Succeed
      else
        result.msg = msg
      end
    end
  end
  return result
end

function PlayerGoodsShelfServer:GoodsShelfBuyClothes(param)
  self:pam_stopMotion()
  local shelfID = param.shelfID
  local type = param.type or Define.GoodsShelf.Type.None
  local ids = param.ids
  local totalPrice = 0
  for i, id in pairs(ids) do
    local config = ClothesConfig:getCfgById(id)
    if config then
      totalPrice = totalPrice + config.price
    end
  end
  local cash = self:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if totalPrice > cash then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "goods_shelf.no.enough.currency"
    return result
  end
  self:payCurrencyById(Define.Bastion.Currency.Type.Gold, totalPrice, Define.CurrencyReason.Clothes)
  for i, id in pairs(ids) do
    self:GoodsShelfDeliver(shelfID, type, id)
  end
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.Succeed
  result.msg = "OK"
  return result
end

function PlayerGoodsShelfServer:GoodsShelfBuyCar(param)
  self:pam_stopMotion()
  local shelfID = param.shelfID
  local type = param.type or Define.GoodsShelf.Type.None
  local id = param.id
  local config = VehicleBaseConfig:getCfgById(id)
  if not config then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "no such config"
    return result
  end
  local price = config.vehicle_price
  local cash = self:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if price > cash then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "goods_shelf.no.enough.currency"
    return result
  end
  self:payCurrencyById(Define.Bastion.Currency.Type.Gold, price, Define.CurrencyReason.BuyCar)
  self:GoodsShelfDeliver(shelfID, type, id)
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.Succeed
  result.msg = "OK"
  return result
end

function PlayerGoodsShelfServer:GoodsShelfBuyItem(param)
  self:pam_stopMotion()
  local shelfID = param.shelfID
  local type = param.type or Define.GoodsShelf.Type.None
  local id = param.id
  local config = GoodsBaseConfig:getCfgById(id)
  if not config then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "no such config"
    return result
  end
  local price = config.price or 0
  local cash = self:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if price > cash then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "goods_shelf.no.enough.currency"
    return result
  end
  self:payCurrencyById(Define.Bastion.Currency.Type.Gold, price, Define.CurrencyReason.BuyItem)
  self:GoodsShelfDeliver(shelfID, type, id)
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.Succeed
  result.msg = "OK"
  return result
end

function PlayerGoodsShelfServer:GoodsShelfBuyBlackMarketItem(param)
  self:pam_stopMotion()
  local shelfID = param.shelfID
  local goodsID = param.id
  local config = BlackMarketGoodsConfig:getCfgById(goodsID)
  if not config then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "no such item"
    return result
  end
  local price = config.price
  local cash = self:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if price > cash then
    local result = {}
    result.status = Define.GoodsShelf.PurchaseErrorCode.Failed
    result.msg = "goods_shelf.no.enough.currency"
    return result
  end
  self:payCurrencyById(Define.Bastion.Currency.Type.Gold, price, Define.CurrencyReason.BlackMarket)
  local goodsList = config.goods or {}
  for i, goods in pairs(goodsList) do
    local type = goods.type
    local id = goods.id
    self:GoodsShelfDeliver(shelfID, type, id, true)
  end
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.Succeed
  result.msg = "OK"
  return result
end

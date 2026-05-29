local BlackMarketGoodsConfig = T(Config, "BlackMarketGoodsConfig")
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.black_market_cache = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBlackMarket = Entity

function EntityBlackMarket:bmc_getCache()
  return self:getValue("black_market_cache") or {}
end

function EntityBlackMarket:bmc_setCache(cache)
  self:setValue("black_market_cache", cache)
end

function EntityBlackMarket:bmc_getMarketDict()
  local cache = self:bmc_getCache()
  return cache.marketDict or {}
end

function EntityBlackMarket:bmc_setMarketDict(dict)
  local cache = self:bmc_getCache()
  cache.marketDict = dict
  self:bmc_setCache(cache)
end

function EntityBlackMarket:bmc_getMarket(id)
  local dict = self:bmc_getMarketDict()
  return dict[id]
end

function EntityBlackMarket:bmc_setMarket(id, item)
  local dict = self:bmc_getMarketDict()
  dict[id] = item
  self:bmc_setMarketDict(dict)
end

function EntityBlackMarket:bmc_getGoods(id)
  local item = self:bmc_getMarket(id)
  if World.isClient then
    if not item then
      item = {}
    end
  else
    local currentTime = os.time()
    if not item or currentTime > item.expiration then
      local newMarket = self:bmc_createRandomMarket(id)
      self:bmc_setMarket(id, newMarket)
      item = self:bmc_getMarket(id)
    end
  end
  return item.goods or {}
end

function EntityBlackMarket:bmc_createRandomMarket(id)
  local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
  local reloadTime = shelfConfigItem.reloadTime
  local rules = shelfConfigItem.goodsRules
  local totalGoods = {}
  for i, rule in pairs(rules) do
    local type = rule.type
    local amount = rule.amount
    local goodsArray = BlackMarketGoodsConfig:drawGoods(type, amount)
    for i, goods in pairs(goodsArray) do
      table.insert(totalGoods, goods.id)
    end
  end
  local item = {}
  item.expiration = os.time() + reloadTime
  item.goods = totalGoods
  return item
end

function EntityBlackMarket:bmc_reloadMarket(id)
  self:bmc_getGoods(id)
end

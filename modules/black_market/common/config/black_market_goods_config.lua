local BastionServer = T(Lib, "BastionServer")
local BlackMarketGoodsConfig = T(Config, "BlackMarketGoodsConfig")
local settings = {}
local typeToGoodsSamplesDict = {}

function BlackMarketGoodsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/black_market_goods.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.type = tonumber(vConfig.n_type) or 0
    item.weight = tonumber(vConfig.n_weight) or 0
    item.icon = vConfig.s_icon
    item.goods = self:parseGoodsList(vConfig.s_goods or "")
    item.price = tonumber(vConfig.n_price) or 0
    settings[item.id] = item
  end
end

function BlackMarketGoodsConfig:parseType(type)
  local str = Define.GoodsShelf.Type.None
  if type == 1 then
    str = Define.GoodsShelf.Type.Clothes
  elseif type == 2 then
    str = Define.GoodsShelf.Type.Cars
  elseif type == 3 then
    str = Define.GoodsShelf.Type.Weapons
  elseif type == 4 then
    str = Define.GoodsShelf.Type.BlackMarket
  elseif type == 5 then
    str = Define.GoodsShelf.Type.Bullet
  elseif type == 8 then
    str = Define.GoodsShelf.Type.Item
  end
  return str
end

function BlackMarketGoodsConfig:parseGoodsItem(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "-")
  local good = {}
  good.type = self:parseType(tonumber(samplesStr[1]) or Define.GoodsShelf.Type.None)
  good.id = tonumber(samplesStr[2]) or 0
  return good
end

function BlackMarketGoodsConfig:parseGoodsList(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local goodsList = {}
  for i, str in pairs(samplesStr) do
    local item = self:parseGoodsItem(str)
    table.insert(goodsList, item)
  end
  return goodsList
end

function BlackMarketGoodsConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgBlackMarketGoodsConfig, id:", id)
    return
  end
  return settings[id]
end

function BlackMarketGoodsConfig:getAllCfgs()
  return settings
end

function BlackMarketGoodsConfig:getGoodsArrayWithType(type)
  local goodsSamples = typeToGoodsSamplesDict[type]
  if not goodsSamples then
    goodsSamples = {}
    for i, item in pairs(settings) do
      if item.type == type then
        local sample = {
          value = item,
          weight = item.weight
        }
        table.insert(goodsSamples, sample)
      end
    end
    typeToGoodsSamplesDict[type] = goodsSamples
  end
  return goodsSamples
end

function BlackMarketGoodsConfig:drawGoods(type, amount)
  local samples = self:getGoodsArrayWithType(type)
  return BastionServer:export_getNSamples(samples, amount)
end

BlackMarketGoodsConfig:init()
return BlackMarketGoodsConfig

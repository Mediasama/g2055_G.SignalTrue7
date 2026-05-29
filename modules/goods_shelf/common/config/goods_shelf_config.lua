local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local settings = {}

function GoodsShelfConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/goods_shelf.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.type = self:parseType(vConfig.n_type or "")
    item.buttonIcon = vConfig.s_button_icon or ""
    item.buttonText = vConfig.s_button_text or ""
    item.position = self:parseTransform(vConfig.s_position or "")
    item.rotation = self:parseTransform(vConfig.s_rotation or "")
    item.carposition = self:parseFacilityInfo(vConfig.s_carposition or "")
    item.goodsList = self:parseGoodsList(vConfig.s_goods or "")
    item.reloadTime = tonumber(vConfig.n_reload_time) or 0
    item.goodsRules = self:parseGoodsRules(vConfig.s_goods_rule or "")
    settings[item.id] = item
  end
end

function GoodsShelfConfig:parseType(dataStr)
  local type = tonumber(dataStr) or 0
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
  end
  return str
end

function GoodsShelfConfig:parseTransform(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local x = tonumber(samplesStr[1]) or 0
  local y = tonumber(samplesStr[2]) or 0
  local z = tonumber(samplesStr[3]) or 0
  return Vector3.new(x, y, z)
end

function GoodsShelfConfig:parseFacilityInfo(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "#")
  local result = {}
  result.position = self:parseTransform(samplesStr[1] or "")
  result.rotation = self:parseTransform(samplesStr[2] or "")
  return result
end

function GoodsShelfConfig:parseGoodsList(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local goodsList = {}
  for i, str in pairs(samplesStr) do
    local id = tonumber(str)
    if id then
      table.insert(goodsList, id)
    end
  end
  return goodsList
end

function GoodsShelfConfig:parseGoodsRuleItem(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "-")
  local type = tonumber(samplesStr[1]) or 0
  local amount = tonumber(samplesStr[2]) or 0
  return {type = type, amount = amount}
end

function GoodsShelfConfig:parseGoodsRules(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local rules = {}
  for i, str in pairs(samplesStr) do
    local rule = self:parseGoodsRuleItem(str)
    table.insert(rules, rule)
  end
  return rules
end

function GoodsShelfConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgGoodsShelfConfig, id:", id)
    return
  end
  return settings[id]
end

function GoodsShelfConfig:getAllCfgs()
  return settings
end

GoodsShelfConfig:init()
return GoodsShelfConfig

local ClothesConfig = T(Config, "ClothesConfig")
local settings = {}

function ClothesConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/clothes.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.part = tonumber(vConfig.n_part) or Define.ModelClothes.Type.None
    item.take_off_part = Define.ModelClothes.Type.None
    item.is_tattoo = (tonumber(vConfig.b_is_tattoo) or 0) == 1
    if item.is_tattoo then
      item.take_off_part = item.part
      item.part = Define.ModelClothes.Type.Tattoo
    end
    item.skin_data = self:parseSkinData(vConfig.s_skin_data or "")
    item.iconBoy = vConfig.s_icon_boy
    item.iconGirl = vConfig.s_icon_girl
    item.price = tonumber(vConfig.n_price) or 0
    item.currencyType = tonumber(vConfig.n_currency_type) or 0
    settings[item.id] = item
  end
end

function ClothesConfig:parseSkinData(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "=")
  local data = {}
  data[samplesStr[1]] = samplesStr[2] or ""
  return data
end

function ClothesConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgClothesConfig, id:", id)
    return
  end
  return settings[id]
end

function ClothesConfig:getAllCfgs()
  return settings
end

ClothesConfig:init()
return ClothesConfig

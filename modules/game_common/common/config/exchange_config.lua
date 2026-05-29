local ExchangeConfig = T(Config, "ExchangeConfig")
local settings = {}

function ExchangeConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/exchange.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.id) or 0,
      cost = tonumber(vConfig.cost) or 0,
      num = tonumber(vConfig.num) or 0
    }
    table.insert(settings, data)
  end
end

function ExchangeConfig:getCfgByIndex(index)
  if not settings[index] then
    Lib.logError("can not find cfgExchangeConfig, index:", index)
    return
  end
  return settings[index]
end

function ExchangeConfig:getAllCfgs()
  return settings
end

function ExchangeConfig:getItemNum()
  return #settings
end

ExchangeConfig:init()
return ExchangeConfig

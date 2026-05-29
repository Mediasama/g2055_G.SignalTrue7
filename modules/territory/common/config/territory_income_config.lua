local TerritoryIncomeConfig = T(Config, "TerritoryIncomeConfig")
local settings = {}

function TerritoryIncomeConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/territory_income.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      player_area = vConfig.s_player_area or "",
      delta = tonumber(vConfig.n_delta) or 0
    }
    if settings[data.id] == nil then
      settings[data.id] = {}
    end
    local tmp = Lib.splitString(data.player_area, ",")
    local max = tmp[2]
    if max == "#" then
      max = 999999
    else
      max = tonumber(tmp[2])
    end
    data.player_area = {
      min = tonumber(tmp[1]),
      max = max
    }
    settings[data.id][#settings[data.id] + 1] = data
  end
end

function TerritoryIncomeConfig:getIncomeDelta(id, playerNumber)
  local cfg = self:getCfgById(id)
  if cfg then
    for i = 1, #cfg do
      if playerNumber >= cfg[i].player_area.min and playerNumber <= cfg[i].player_area.max then
        return cfg[i].delta
      end
    end
  end
  return 1
end

function TerritoryIncomeConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgTerritoryIncomeConfig, id:", id)
    return
  end
  return settings[id]
end

function TerritoryIncomeConfig:getAllCfgs()
  return settings
end

TerritoryIncomeConfig:init()
return TerritoryIncomeConfig

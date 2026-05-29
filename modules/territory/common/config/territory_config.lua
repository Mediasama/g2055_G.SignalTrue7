local TerritoryConfig = T(Config, "TerritoryConfig")
local settings = {}

function TerritoryConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/territory.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      type = tonumber(vConfig.n_type) or 0,
      cfg_name = vConfig.s_cfg_name or "",
      name = vConfig.s_name or "",
      effect = vConfig.s_effect or "",
      effect_me = vConfig.s_effect_me or "",
      progress_effect = vConfig.s_progress_effect or "",
      income_progress_effect = vConfig.s_income_progress_effect or "",
      basic_income = tonumber(vConfig.n_basic_income) or 0,
      max_income = tonumber(vConfig.n_max_income) or 0,
      income_time = tonumber(vConfig.n_income_time) or 0,
      occupy_time = tonumber(vConfig.n_occupy_time) or 0,
      icon = vConfig.s_icon or "",
      area_id = vConfig.n_area_id or 0,
      area_cfg_name = vConfig.s_area_cfg_name or "",
      area_icon = vConfig.s_area_icon or ""
    }
    local tmpPos = Lib.splitString(vConfig.s_pos, ",")
    data.pos = {
      x = tonumber(tmpPos[1]),
      y = tonumber(tmpPos[2]),
      z = tonumber(tmpPos[3])
    }
    tmpPos = Lib.splitString(vConfig.s_area_entity_pos, ",")
    data.area_entity_pos = {
      x = tonumber(tmpPos[1]),
      y = tonumber(tmpPos[2]),
      z = tonumber(tmpPos[3])
    }
    tmpPos = Lib.splitString(vConfig.s_area_pos, ",")
    data.area_pos = {
      x = tonumber(tmpPos[1]),
      y = tonumber(tmpPos[2]),
      z = tonumber(tmpPos[3])
    }
    tmpPos = Lib.splitString(vConfig.s_icon_gang_pos, ",")
    data.icon_gang_pos = {
      x = tonumber(tmpPos[1]),
      y = tonumber(tmpPos[2])
    }
    local tmp = Lib.split(vConfig.s_progress_effect_cfg, "&")
    data.progress_effect_cfg = {
      num = tonumber(tmp[1]),
      radius = tonumber(tmp[2]),
      yDelta = tonumber(tmp[3])
    }
    tmp = Lib.split(vConfig.s_income_progress_effect_cfg, "&")
    data.income_progress_effect_cfg = {
      num = tonumber(tmp[1]),
      radius = tonumber(tmp[2]),
      yDelta = tonumber(tmp[3])
    }
    tmp = Lib.split(vConfig.s_effect_cfg, "&")
    data.effect_cfg = {
      num = tonumber(tmp[1]),
      radius = tonumber(tmp[2]),
      yDelta = tonumber(tmp[3])
    }
    tmp = Lib.split(vConfig.s_effect_cfg_me, "&")
    data.effect_cfg_me = {
      num = tonumber(tmp[1]),
      radius = tonumber(tmp[2]),
      yDelta = tonumber(tmp[3])
    }
    settings[data.id] = data
  end
end

function TerritoryConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgTerritoryConfig, id:", id)
    return
  end
  return settings[id]
end

function TerritoryConfig:getAllCfgs()
  return settings
end

TerritoryConfig:init()
return TerritoryConfig

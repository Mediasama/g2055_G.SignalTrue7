local PassCardQuestConfig = T(Config, "PassCardQuestConfig")
local settings = {}

function PassCardQuestConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pass_card_quest.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      remark = vConfig.s_remark or "",
      type = tonumber(vConfig.n_type) or 0,
      sub_type = tonumber(vConfig.n_sub_type) or 0,
      target_num = tonumber(vConfig.n_target_num) or 0,
      detail = vConfig.s_detail or "",
      exp = tonumber(vConfig.n_exp) or 0,
      day_limit = tonumber(vConfig.n_day_limit) or 0,
      save = tonumber(vConfig.n_save) or 0,
      is_active = tonumber(vConfig.n_is_active) or 0
    }
    settings[data.id] = data
  end
end

function PassCardQuestConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPassCardQuestConfig, id:", id)
    return
  end
  return settings[id]
end

function PassCardQuestConfig:getAllCfgs()
  return settings
end

PassCardQuestConfig:init()
return PassCardQuestConfig

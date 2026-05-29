local GuideConfig = T(Config, "GuideConfig")
local Dict = {}

function GuideConfig:initGuideConfig()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/guide.csv", 2)
  for _, vConfig in pairs(config) do
    local id = tonumber(vConfig.n_id) or 0
    local data = {
      id = id,
      type = tonumber(vConfig.type) or 1,
      desc = vConfig.s_desc or "",
      effect_pos = vConfig.effect_pos and Lib.splitString(vConfig.effect_pos, ","),
      ui_pos = vConfig.ui_pos and Lib.splitString(vConfig.ui_pos, ","),
      isSave = tonumber(vConfig.n_isSave) == 1,
      goldCount = tonumber(vConfig.n_goldCount),
      guideParent = tonumber(vConfig.n_parent) or 0
    }
    Dict[data.id] = data
  end
end

function GuideConfig:getGuideDict()
  return Dict
end

function GuideConfig:getCfgById(id)
  local cfg = Dict[id]
  if not cfg then
    Lib.logError("can not find GuideConfig, id:", id)
    return
  end
  return cfg
end

GuideConfig:initGuideConfig()
return GuideConfig

local GangIconConfig = T(Config, "GangIconConfig")
local settings = {}
local setting_array = {}

function GangIconConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/gang_icon.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      icon_button = vConfig.s_icon_button or "",
      icon_create = vConfig.s_icon_create or "",
      entity_actor = vConfig.s_entity_actor or ""
    }
    settings[data.id] = data
    setting_array[#setting_array + 1] = data
  end
end

function GangIconConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgGangIconConfig, id:", id)
    return
  end
  return settings[id]
end

function GangIconConfig:getGangButtonIcon(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.icon_button
  end
end

function GangIconConfig:getGangCreateIcon(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.icon_create
  end
end

function GangIconConfig:getGangFlagActor(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.entity_actor
  end
end

function GangIconConfig:getAllCfgs()
  return setting_array
end

GangIconConfig:init()
return GangIconConfig

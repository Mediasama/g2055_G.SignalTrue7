local SceneTriggersConfig = T(Config, "SceneTriggersConfig")
local settings = {}

function SceneTriggersConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/scene_triggers.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.entity_cfg = vConfig.s_entity_cfg or ""
    item.position = self:parseTransform(vConfig.s_position or "")
    item.rotation = self:parseTransform(vConfig.s_rotation or "")
    settings[item.id] = item
  end
end

function SceneTriggersConfig:parseTransform(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local x = tonumber(samplesStr[1]) or 0
  local y = tonumber(samplesStr[2]) or 0
  local z = tonumber(samplesStr[3]) or 0
  return Vector3.new(x, y, z)
end

function SceneTriggersConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgSceneTriggersConfig, id:", id)
    return
  end
  return settings[id]
end

function SceneTriggersConfig:getAllCfgs()
  return settings
end

SceneTriggersConfig:init()
return SceneTriggersConfig

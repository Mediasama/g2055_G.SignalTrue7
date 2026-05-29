local AtmConfig = T(Config, "AtmConfig")
local settings = {}

function AtmConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/atm.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      type = tonumber(vConfig.n_type) or 0,
      description = vConfig.s_description or "",
      entityName = vConfig.s_entityName or "",
      cd = tonumber(vConfig.n_cd) or 0,
      loot_cd = tonumber(vConfig.n_loot_cd) or 0,
      all_money = tonumber(vConfig.n_all_money) or 0,
      hp = tonumber(vConfig.n_hp) or 1,
      loot_min = tonumber(vConfig.n_loot_min) or 0,
      loot_max = tonumber(vConfig.n_loot_max) or 0,
      pos = self:parseFacilityInfo(vConfig.s_pos or "")
    }
    settings[data.id] = data
  end
end

function AtmConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgAtmConfig, id:", id)
    return
  end
  return settings[id]
end

function AtmConfig:parseTransform(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local x = tonumber(samplesStr[1]) or 0
  local y = tonumber(samplesStr[2]) or 0
  local z = tonumber(samplesStr[3]) or 0
  return Vector3.new(x, y, z)
end

function AtmConfig:parseFacilityInfo(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "#")
  local result = {}
  result.position = self:parseTransform(samplesStr[1] or "")
  result.rotation = self:parseTransform(samplesStr[2] or "")
  return result
end

function AtmConfig:getAllCfgs()
  return settings
end

AtmConfig:init()
return AtmConfig

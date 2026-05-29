local NpcDoorsConfig = T(Config, "NpcDoorsConfig")
local settings = {}

function NpcDoorsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc_doors.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.door_id = tonumber(vConfig.n_door_id) or 0
    item.position = self:parseTransform(vConfig.s_position)
    item.rotation = self:parseTransform(vConfig.s_rotation)
    settings[item.id] = item
  end
end

function NpcDoorsConfig:parseTransform(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local x = tonumber(samplesStr[1]) or 0
  local y = tonumber(samplesStr[2]) or 0
  local z = tonumber(samplesStr[3]) or 0
  return Vector3.new(x, y, z)
end

function NpcDoorsConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgNpcDoorsConfig, id:", id)
    return
  end
  return settings[id]
end

function NpcDoorsConfig:getAllCfgs()
  return settings
end

NpcDoorsConfig:init()
return NpcDoorsConfig

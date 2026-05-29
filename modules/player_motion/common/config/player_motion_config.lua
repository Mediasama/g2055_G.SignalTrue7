local PlayerMotionConfig = T(Config, "PlayerMotionConfig")
local settings = {}

function PlayerMotionConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/player_motion.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      description = vConfig.s_description or "",
      name = vConfig.s_name or "",
      icon = vConfig.s_icon or "",
      actionKey = vConfig.s_action_key or "",
      skinData = self:parseSkinData(vConfig.s_skin_data or ""),
      ifPaidMotion = tonumber(vConfig.n_if_paid_motion) == 1
    }
    settings[data.id] = data
  end
end

function PlayerMotionConfig:parseSkinData(dataStr)
  local skinData = {gun = dataStr}
  return skinData
end

function PlayerMotionConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPlayerMotionConfig, id:", id)
    return
  end
  return settings[id]
end

function PlayerMotionConfig:getAllCfgs()
  return settings
end

PlayerMotionConfig:init()
return PlayerMotionConfig

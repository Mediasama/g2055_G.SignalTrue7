local PassCardConfig = T(Config, "PassCardConfig")
local settings = {}

function PassCardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pass_card.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      level = tonumber(vConfig.n_level) or 0,
      exp = tonumber(vConfig.n_exp) or 0,
      reward_free = self:parseReward(vConfig.s_reward_free or "", false),
      icon_free = vConfig.s_icon_free or "",
      reward_gold = self:parseReward(vConfig.s_reward_gold or "", true),
      icon_gold = vConfig.s_icon_gold or "",
      price = tonumber(vConfig.n_price) or 0
    }
    settings[data.level] = data
  end
end

function PassCardConfig:parseReward(dataStr, isGold)
  local samplesStr = Lib.splitString(dataStr or "", "#")
  local type = tonumber(samplesStr[1]) or -1
  local id = tonumber(samplesStr[2]) or -1
  local num = tonumber(samplesStr[3]) or -1
  return {
    type = type,
    id = id,
    num = num,
    isGold = isGold
  }
end

function PassCardConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPassCardConfig, id:", id)
    return
  end
  return settings[id]
end

function PassCardConfig:getAllCfgs()
  return settings
end

function PassCardConfig:getMaxLevel()
  return #settings
end

PassCardConfig:init()
return PassCardConfig

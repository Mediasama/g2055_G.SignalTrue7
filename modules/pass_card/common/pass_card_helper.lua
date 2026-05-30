local PassCardHelper = T(Lib, "PassCardHelper")
local PassCardConfig = T(Config, "PassCardConfig")

function PassCardHelper:getConfigPassCardDate()
  local beginDateStr = World.cfg.passCardBeginDate
  local endDateStr = World.cfg.passCardEndDate
  if beginDateStr and endDateStr then
    local function getDate(dateStr)
      local dateArray = Lib.splitString(dateStr, ".")
      
      local year = tonumber(dateArray[1])
      local month = tonumber(dateArray[2])
      local day = tonumber(dateArray[3])
      if year and month and day then
        return {
          year = year,
          month = month,
          day = day,
          hour = 0
        }
      end
      return nil
    end
    
    local passCardBeginDate = getDate(beginDateStr)
    local passCardEndDate = getDate(endDateStr)
    return passCardBeginDate, passCardEndDate
  end
  return nil, nil
end

function PassCardHelper:isPassCardDate(beginDate, endDate)
  return true -- Pass is always active
end

function PassCardHelper:calLevelUp(playerPassCard)
  if not playerPassCard or not playerPassCard.level then
    return
  end
  local cfg = PassCardConfig:getCfgById(playerPassCard.level)
  if cfg and playerPassCard.exp >= cfg.exp and playerPassCard.level < PassCardConfig:getMaxLevel() then
    playerPassCard.level = playerPassCard.level + 1
    playerPassCard.exp = playerPassCard.exp - cfg.exp
    if playerPassCard.level >= PassCardConfig:getMaxLevel() then
      playerPassCard.exp = 0
    end
    return PassCardHelper:calLevelUp(playerPassCard)
  end
end

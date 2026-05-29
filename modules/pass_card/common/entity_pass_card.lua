local PassCardHelper = T(Lib, "PassCardHelper")
local PassCardConfig = T(Config, "PassCardConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.playerPassCard = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.playerPassCardDate = {
  false,
  false,
  true,
  false,
  {},
  true
}
local Entity = _ENV.Entity

function Entity:getPlayerPassCardDate()
  return self:getValue("playerPassCardDate")
end

function Entity:setPlayerPassCardDate(beginDate, endDate)
  local date = self:getPlayerPassCardDate()
  date.passCardBeginDate = beginDate
  date.passCardEndDate = endDate
  return self:setValue("playerPassCardDate", date)
end

function Entity:initPlayerPassCardDate()
  local beingDate, endDate = PassCardHelper:getConfigPassCardDate()
  self:setPlayerPassCardDate(beingDate, endDate)
end

function Entity:getPlayerPassCard()
  return self:getValue("playerPassCard")
end

function Entity:checkPlayerPassCard()
  if not self:isPassCardDate() then
    return
  end
  local passCardData = self:getPlayerPassCard()
  local date = self:getPlayerPassCardDate()
  local sameDate = date.passCardBeginDate and os.time(passCardData.passCardBeginDate) == os.time(date.passCardBeginDate)
  if not passCardData.passCardBeginDate or not sameDate then
    self:initPlayerPassCard()
  else
    self:checkAutoGetPlayMotion()
  end
end

function Entity:checkAutoGetPlayMotion()
  local allcfg = PassCardConfig:getAllCfgs()
  
  local function checkPlayMotionReward(reward, level)
    if reward.type == Define.PassCardRewardType.RewardMotion and not self:checkPlayerMotionPaid(reward.id) and self:playerGotPassCardReward(reward.isGold, level) then
      self:addPlayerMotionPaid(reward.id)
    end
  end
  
  for _, v in pairs(allcfg) do
    local cfg = v
    local freeReward = cfg.reward_free
    checkPlayMotionReward(freeReward, cfg.level)
    local goldReward = cfg.reward_gold
    checkPlayMotionReward(goldReward, cfg.level)
  end
end

function Entity:initPlayerPassCard()
  if not self:isPassCardDate() then
    return
  end
  local date = self:getPlayerPassCardDate()
  local data = {}
  data.level = 1
  data.exp = 0
  data.hasGoldCard = false
  data.passCardBeginDate = Lib.copy(date.passCardBeginDate)
  data.freeRewardStatus = {}
  data.goldRewardStatus = {}
  self:setValue("playerPassCard", data)
  Lib.logInfo(">>>>>>>>>>>>>>>>>>>>>>> initPlayerPassCard:  ", data.passCardBeginDate)
end

function Entity:buyPlayerPassCard()
  if not self:isPassCardDate() then
    return
  end
  local passCardData = self:getPlayerPassCard()
  passCardData.hasGoldCard = true
  self:setValue("playerPassCard", passCardData)
end

function Entity:playerPassCardAddExp(exp)
  if not self:isPassCardDate() then
    return 0
  end
  if not (not self:playerPassCardMaxLevel() and exp) or exp <= 0 then
    return 0
  end
  local passCardData = self:getPlayerPassCard()
  local oldLevel = passCardData.level
  passCardData.exp = passCardData.exp + exp
  PassCardHelper:calLevelUp(passCardData)
  self:setValue("playerPassCard", passCardData)
  self:sendPacket({
    pid = "passCardAddExpS2C"
  })
  if oldLevel < passCardData.level then
    self:sendPacket({
      pid = "passCardLevelUpS2C"
    })
  end
  return exp
end

function Entity:playerPassCardMaxLevel()
  local passCardData = self:getPlayerPassCard()
  return passCardData.level and passCardData.level >= PassCardConfig:getMaxLevel()
end

function Entity:playerPassCardGetReward(isGold, level)
  if not self:isPassCardDate() or not level then
    return
  end
  local passCardData = self:getPlayerPassCard()
  local rewardStatus = isGold and passCardData.goldRewardStatus or passCardData.freeRewardStatus
  rewardStatus[level] = Define.PassCardRewardStatus.Got
  self:setValue("playerPassCard", passCardData)
end

function Entity:playerGotPassCardReward(isGold, level)
  if not level then
    return false
  end
  local passCardData = self:getPlayerPassCard()
  local rewardStatus = isGold and passCardData.goldRewardStatus or passCardData.freeRewardStatus
  return rewardStatus[level] == Define.PassCardRewardStatus.Got
end

function Entity:playerCanGetPassCardReward(isGold, level)
  if not level then
    return false
  end
  local passCardData = self:getPlayerPassCard()
  local cfg = PassCardConfig:getCfgById(level)
  local reward
  if cfg then
    reward = isGold and cfg.reward_gold or cfg.reward_free
  end
  if not reward or not reward.type then
    return false
  end
  local rewardStatus = isGold and passCardData.goldRewardStatus or passCardData.freeRewardStatus
  return rewardStatus[level] ~= Define.PassCardRewardStatus.Got and reward.type > 0 and level <= passCardData.level
end

function Entity:checkPassCardCanGetReward()
  local passCardData = self:getPlayerPassCard()
  for i = 1, passCardData.level do
    local cfg = PassCardConfig:getCfgById(i)
    if cfg and (passCardData.goldRewardStatus[i] ~= Define.PassCardRewardStatus.Got and passCardData.hasGoldCard or passCardData.freeRewardStatus[i] ~= Define.PassCardRewardStatus.Got) and (cfg.reward_free.type > 0 or passCardData.hasGoldCard and 0 < cfg.reward_gold.type) then
      return true
    end
  end
  return false
end

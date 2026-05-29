local PassCardQuestHelper = T(Lib, "PassCardQuestHelper")
local PassCardQuestConfig = T(Config, "PassCardQuestConfig")

function PassCardQuestHelper:init()
  self.lastResetDailyLimitStamp = 0
  World.Timer(20, function()
    self:checkResetDailyLimit()
    return true
  end)
end

function PassCardQuestHelper:checkResetDailyLimit()
  local date = os.date("*t")
  if date.hour == 0 and date.min == 0 then
    local time = os.time()
    if time - self.lastResetDailyLimitStamp >= 86400 then
      print("*********************************************  checkResetDailyLimit ", date.year, date.month, date.day, date.sec, self.lastResetDailyLimitStamp)
      self.lastResetDailyLimitStamp = time
      local allPlayer = Game.GetAllPlayers()
      for _, player in pairs(allPlayer) do
        if player and player:isValid() then
          player:clearDailyLimit()
        end
      end
    end
  end
end

function PassCardQuestHelper:updateQuest(player, questType, subType, num)
  if not player:isPassCardDate() then
    return
  end
  if not (player and questType and subType and num) or num <= 0 then
    return
  end
  local questDic = player:getPlayerPassCardQuest().questItemDic
  if not questDic then
    return
  end
  for _, v in pairs(questDic) do
    local quest = v
    local cfg = PassCardQuestConfig:getCfgById(quest.id)
    if cfg.type == questType and cfg.sub_type == subType and 0 < cfg.target_num and (quest.sumExp < cfg.day_limit or 0 > cfg.day_limit) then
      local total = quest.progress + num
      local multiple = math.floor(total / cfg.target_num)
      local remain = math.floor(total % cfg.target_num)
      local exp = multiple * cfg.exp
      if 0 < cfg.day_limit then
        exp = math.min(exp, cfg.day_limit - quest.sumExp)
      end
      if 0 < exp then
        quest.sumExp = quest.sumExp + player:playerPassCardAddExp(exp)
        local reportData = {}
        reportData.passcard_task_id = quest.id
        reportData.passcard_task_Limit = quest.sumExp
        reportData.passcard_exp = player:getPlayerPassCard().exp
        player:evt_reportEvent(Define.EventTracking.Type.PassCardTaskFinish, reportData, true)
      end
      quest.progress = remain
    end
  end
  player:setPassCardQuestDic(questDic)
end

function PassCardQuestHelper:needReset(date1, date2)
  if date1 and date2 then
    return date1.year ~= date2.year or date1.month ~= date2.month or date1.day ~= date2.day
  end
  return false
end

PassCardQuestHelper:init()

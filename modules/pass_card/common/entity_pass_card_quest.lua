local PassCardQuestConfig = T(Config, "PassCardQuestConfig")
local PassCardQuestHelper = T(Lib, "PassCardQuestHelper")
local ValueDef = T(Entity, "ValueDef")
ValueDef.playerPassCardQuest = {
  false,
  false,
  true,
  false,
  {},
  true
}
local Entity = _ENV.Entity

function Entity:getPlayerPassCardQuest()
  return self:getValue("playerPassCardQuest")
end

function Entity:setPlayerPassCardQuest(data)
  self:setValue("playerPassCardQuest", data)
end

function Entity:getPassCardQuestDic()
  return self:getValue("playerPassCardQuest").questItemDic
end

function Entity:setPassCardQuestDic(dic, dontSaveTime)
  if not self:isPassCardDate() then
    return
  end
  if not dic then
    return
  end
  local questData = self:getPlayerPassCardQuest()
  questData.questItemDic = dic
  self:setPlayerPassCardQuest(questData)
  if not dontSaveTime then
    self:updateQuestSaveTime()
  end
end

function Entity:getPlayerPassCardQuestItem(id)
  local questData = self:getValue("playerPassCardQuest")
  if questData.questItemDic then
    return questData.questItemDic[id]
  end
  return nil
end

function Entity:checkPlayerPassCardQuest()
  if not self:isPassCardDate() then
    return
  end
  local initForTest = false
  local questDic = {}
  local savedQuestDic = self:getPassCardQuestDic() or {}
  local questList = PassCardQuestConfig:getAllCfgs()
  for _, v in pairs(questList) do
    local questCfg = v
    if questCfg.is_active == 1 then
      local data = {}
      data.id = questCfg.id
      data.type = questCfg.type
      data.subType = questCfg.sub_type
      local savedData = savedQuestDic[questCfg.id]
      if initForTest then
        savedData = nil
      end
      if savedData and savedData.type == questCfg.type and savedData.subType == questCfg.sub_type then
        if questCfg.save == 1 then
          data.progress = math.min(savedData.progress, questCfg.target_num)
        else
          data.progress = 0
        end
        if 0 < questCfg.day_limit then
          data.sumExp = math.min(savedData.sumExp, questCfg.day_limit)
        else
          data.sumExp = 0
        end
      else
        data.progress = 0
        data.sumExp = 0
      end
      questDic[data.id] = data
    end
  end
  local questData = self:getPlayerPassCardQuest()
  if next(questData) == nil then
    local data = {}
    data.saveTime = nil
    data.questItemDic = questDic
    self:setPlayerPassCardQuest(data)
    Lib.logInfo(">>>>>>>>>>>>>>>>>>>>>>> checkPlayerPassCardQuest,empty")
  else
    self:setPassCardQuestDic(questDic, true)
    self:checkClearDailyLimit()
  end
end

function Entity:checkClearDailyLimit()
  if not self:isPassCardDate() then
    return
  end
  local questData = self:getPlayerPassCardQuest()
  if questData.saveTime then
    local date = os.date("*t")
    if PassCardQuestHelper:needReset(date, questData.saveTime) then
      self:clearDailyLimit()
    end
  end
end

function Entity:clearDailyLimit()
  local questData = self:getPlayerPassCardQuest()
  if questData.questItemDic then
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> clearDailyLimit ", self.platformUserId)
    for _, v in pairs(questData.questItemDic) do
      local questItem = v
      questItem.sumExp = 0
    end
    self:setPassCardQuestDic(questData.questItemDic)
  end
end

function Entity:updatePassCardQuest(questType, subType, num)
  if not self:isPassCardDate() then
    return
  end
  if not (questType and subType and num) or num <= 0 then
    return
  end
  PassCardQuestHelper:updateQuest(self, questType, subType, num)
end

function Entity:updateQuestSaveTime()
  if not self:isPassCardDate() then
    return
  end
  local questData = self:getPlayerPassCardQuest()
  questData.saveTime = os.date("*t")
  self:setPlayerPassCardQuest(questData)
end

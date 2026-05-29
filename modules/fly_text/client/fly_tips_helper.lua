local FlyTipsHelper = {}
local flyTipsSetting = World.cfg.flyTipsSetting or {}

function FlyTipsHelper:init()
  self.tipsItemWait = {}
  self.tipsItemMsg = {}
  self.tipsItemCache = {}
  self:stopUpdateItemList()
end

function FlyTipsHelper:stopUpdateItemList()
  if self.updateTimer then
    self.updateTimer()
    self.updateTimer = nil
  end
  self.curTimeCounts = 0
end

function FlyTipsHelper:pushOneFlyTipsItem(itemInfo)
  table.insert(self.tipsItemWait, itemInfo)
  if not self.updateTimer then
    self:startUpdateItemList()
  end
end

function FlyTipsHelper:startUpdateItemList()
  if not self.updateTimer then
    local ticks = flyTipsSetting.tipsFresh or 2
    self.updateTimer = World.LightTimer("FlyTipsHelper:startUpdateItemList", ticks, function()
      self:updateItemListShow()
      return true
    end)
  end
end

function FlyTipsHelper:updateItemListShow()
  self.curTimeCounts = self.curTimeCounts + 1
  for k, val in pairs(self.tipsItemMsg) do
    if k == 1 then
      local lastPosY = self.tipsItemMsg[k]:getItemYPosition()
      if lastPosY > flyTipsSetting.minPosY then
        local newPosY = lastPosY - flyTipsSetting.oneTimeDistance
        self.tipsItemMsg[k]:setItemYPosition(newPosY)
        local startActionTime = self.tipsItemMsg[k]:getStartActionTime()
        if startActionTime <= 0 then
          self.tipsItemMsg[k]:setStartActionTime(self.curTimeCounts)
        end
      end
    elseif 1 < k then
      local lastPosY = self.tipsItemMsg[k]:getItemYPosition()
      local prePosY = self.tipsItemMsg[k - 1]:getItemYPosition()
      if prePosY < lastPosY - flyTipsSetting.oneTimeDistance - flyTipsSetting.minDistance then
        local newPosY = lastPosY - flyTipsSetting.oneTimeDistance
        self.tipsItemMsg[k]:setItemYPosition(newPosY)
        local startActionTime = self.tipsItemMsg[k]:getStartActionTime()
        if startActionTime <= 0 then
          self.tipsItemMsg[k]:setStartActionTime(self.curTimeCounts)
        end
      end
    end
    local startActionTime = self.tipsItemMsg[k]:getStartActionTime()
    if 0 < startActionTime then
      local passTime = self.curTimeCounts - startActionTime
      if passTime > flyTipsSetting.oneShowTime + flyTipsSetting.oneHideTime then
        self.tipsItemMsg[k]:setAlpha(0)
        self:deleteOneTipsItem(k)
      elseif passTime > flyTipsSetting.oneShowTime then
        local alpha = 1 - (passTime - flyTipsSetting.oneShowTime) / flyTipsSetting.oneHideTime
        self.tipsItemMsg[k]:setAlpha(alpha)
      else
        self.tipsItemMsg[k]:setAlpha(1)
      end
    end
  end
  if 0 < #self.tipsItemWait then
    local curNum = #self.tipsItemMsg
    if 0 < curNum and curNum < flyTipsSetting.maxCount then
      local prePosY = self.tipsItemMsg[curNum]:getItemYPosition()
      if prePosY < flyTipsSetting.initPosY - flyTipsSetting.minDistance then
        self:addOneTipsItemShow(self.tipsItemWait[1])
        table.remove(self.tipsItemWait, 1)
      end
    elseif curNum == 0 then
      self:addOneTipsItemShow(self.tipsItemWait[1])
      table.remove(self.tipsItemWait, 1)
    end
  end
  if 0 >= #self.tipsItemWait and #self.tipsItemMsg <= 0 then
    self:stopUpdateItemList()
    return
  end
end

function FlyTipsHelper:addOneTipsItemShow(itemInfo)
  local newTipItem
  if #self.tipsItemCache > 0 then
    newTipItem = table.remove(self.tipsItemCache, 1)
    table.insert(self.tipsItemMsg, newTipItem)
  else
    newTipItem = UI:openWidget("./UI/main/fly_tips")
    table.insert(self.tipsItemMsg, newTipItem)
    self.parentWin = Me.mainUIWin
    self.parentWin:addChild(newTipItem)
  end
  newTipItem:initItemData(itemInfo)
  newTipItem:setCreateTime(self.curTimeCounts)
  newTipItem:setStartActionTime(0)
end

function FlyTipsHelper:deleteOneTipsItem(deleteKey)
  if #self.tipsItemWait > 0 then
    local cacheTipItem = table.remove(self.tipsItemMsg, deleteKey)
    table.insert(self.tipsItemCache, cacheTipItem)
  else
    local cacheTipItem = table.remove(self.tipsItemMsg, deleteKey)
    self.parentWin:removeChild(cacheTipItem)
  end
end

FlyTipsHelper:init()
return FlyTipsHelper

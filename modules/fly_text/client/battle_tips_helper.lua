local BattleTipsHelper = {}
local flyTipsSetting = World.cfg.battleTipsSetting or {}

function BattleTipsHelper:init()
  self.tipsItemMsg = {}
  self.tipsItemCache = {}
  self:stopUpdateItemList()
end

function BattleTipsHelper:stopUpdateItemList()
  if self.updateTimer then
    self.updateTimer()
    self.updateTimer = nil
  end
  self.curTimeCounts = 0
end

function BattleTipsHelper:pushOneFlyTipsItem(itemInfo)
  local curNum = #self.tipsItemMsg
  if curNum >= flyTipsSetting.maxCount then
    self.tipsItemMsg[1]:setAlpha(0)
    self:deleteOneTipsItem(1)
  end
  self:addOneTipsItemShow(itemInfo)
  if not self.updateTimer then
    self:startUpdateItemList()
  end
end

function BattleTipsHelper:startUpdateItemList()
  if not self.updateTimer then
    local ticks = flyTipsSetting.tipsFresh or 2
    self.updateTimer = World.LightTimer("BattleTipsHelper:startUpdateItemList", ticks, function()
      self:updateItemListShow()
      return true
    end)
  end
end

function BattleTipsHelper:updateItemListShow()
  self.curTimeCounts = self.curTimeCounts + 1
  for k, val in pairs(self.tipsItemMsg) do
    self.tipsItemMsg[k]:setItemYPosition(flyTipsSetting.posYList[k])
    local startActionTime = self.tipsItemMsg[k]:getStartActionTime()
    if startActionTime <= 0 then
      self.tipsItemMsg[k]:setStartActionTime(self.curTimeCounts)
    end
    local startActionTime = self.tipsItemMsg[k]:getStartActionTime()
    if 0 < startActionTime then
      local passTime = self.curTimeCounts - startActionTime
      if passTime > flyTipsSetting.oneShowTime then
        self.tipsItemMsg[k]:setAlpha(0)
        self:deleteOneTipsItem(k)
      else
        self.tipsItemMsg[k]:setAlpha(1)
      end
    end
  end
end

function BattleTipsHelper:addOneTipsItemShow(itemInfo)
  local newTipItem
  if #self.tipsItemCache > 0 then
    newTipItem = table.remove(self.tipsItemCache, 1)
    table.insert(self.tipsItemMsg, newTipItem)
  else
    newTipItem = UI:openWidget("./UI/main/battle_tips")
    table.insert(self.tipsItemMsg, newTipItem)
    self.parentWin = Me.mainUIWin
    self.parentWin:addChild(newTipItem)
  end
  newTipItem:initItemData(itemInfo)
  newTipItem:setCreateTime(self.curTimeCounts)
  newTipItem:setStartActionTime(0)
end

function BattleTipsHelper:deleteOneTipsItem(deleteKey)
  local cacheTipItem = table.remove(self.tipsItemMsg, deleteKey)
  table.insert(self.tipsItemCache, cacheTipItem)
end

BattleTipsHelper:init()
return BattleTipsHelper

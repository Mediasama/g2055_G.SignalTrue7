local LuaTimer = T(Lib, "LuaTimer")
local TerritoryConfig = T(Config, "TerritoryConfig")

function M:init()
  self.buttonOccupy = self:child("ButtonOccupy")
  self.imageOccupyStatusBg = self:child("ImageOccupyStatusBg")
  self.progressBar = self:child("ProgressBar")
  self.imageOccupyStusBg = self:child("ImageOccupyStusBg")
  self.textOccupyStatus = self:child("TextOccupyStatus")
  self.textOccupyStatus = self:child("TextOccupyStatus")
  self.imageOccupyIng = self:child("ImageOccupyIng")
  self.buttonGetAward = self:child("ButtonGetAward")
  self.textOccupyStatus:setText(Lang:toText("territory.ui.tips.occupied"))
  self:initEvent()
end

function M:progressFinish()
  if self.progressTimer then
    LuaTimer:cancel(self.progressTimer)
    self.progressTimer = nil
  end
  self.progressBar:setVisible(false)
  Lib.showScreenMask(false)
  self:showProgress(false)
end

function M:progressStart()
  Lib.showScreenMask(true)
end

function M:showProgress(visible)
  local entity = World.CurWorld:getEntity(self.territoryData.objID)
  if entity then
    entity:setTerritoryVisible(Define.TerritoryEffectType.OccupyEffect, visible)
  end
  local cfg = TerritoryConfig:getCfgById(entity:cfg().territoryId)
  local time = cfg.occupy_time
  if visible then
    self.occupyProgressSound = Me:playSoundByKey("g2055_trigger_territoryOccupying")
  elseif self.occupyProgressSound then
    Me:stopSound(self.occupyProgressSound)
    self.occupyProgressSound = nil
  end
  self.progressBar:setVisible(visible)
  self.imageOccupyIng:setVisible(visible)
  if visible then
    self.imageOccupyStatusBg:setImage("gameres|asset/Imageset/g2055_scenes:img_0_scenebutton_01")
    self.buttonOccupy:setVisible(false)
    self.textOccupyStatus:setVisible(false)
    self:progressStart()
    if time then
      local seconds = 1000 * time / 20
      local times = 100
      local delta = seconds / times
      local index = 1
      self.progressTimer = LuaTimer:scheduleTimerWithEnd(function()
        if not self.progressBar or not self.progressBar.setProgress then
          print("error self.progressTimer = LuaTimer:scheduleTimerWithEnd")
          LuaTimer:cancel(self.progressTimer)
          self.progressTimer = nil
          return
        end
        local pro = index / times
        if 1 < pro then
          pro = 1
        end
        self.progressBar:setProgress(pro)
        index = index + 1
      end, function()
        self.progressTimer = nil
        self:progressFinish()
      end, delta, times)
    end
  end
end

function M:updateView(territoryData)
  self:showProgress(false)
  local territoryOccupied = false
  if territoryData and territoryData.owner and (territoryData.owner == Me.platformUserId or Me:getGangId() == territoryData.owner) then
    territoryOccupied = true
  end
  self.buttonGetAward:setVisible(false)
  self.buttonOccupy:setVisible(not territoryOccupied)
  self.textOccupyStatus:setVisible(true)
  if territoryOccupied then
    self.imageOccupyStatusBg:setImage("gameres|asset/Imageset/g2055_scenes:img_0_scenebutton_01")
    if territoryData.awardCoin > 0 then
      self.buttonGetAward:setVisible(true)
      self.textOccupyStatus:setText(string.format(Lang:getMessage("territory.ui.tips.get.award"), territoryData.awardCoin))
    else
      self.textOccupyStatus:setText(Lang:toText("territory.ui.tips.occupied"))
    end
  else
    self.imageOccupyStatusBg:setImage("gameres|asset/Imageset/g2055_scenes:btn_0_scenebutton_01")
    self.textOccupyStatus:setText(Lang:toText("territory.ui.tips.unOccupied"))
  end
end

function M:initEvent()
  function self.buttonOccupy.onMouseClick()
    Me:occupyTerritory(self.territoryData.objID, function(code)
      if code == Define.TerritoryPacketCode.Success then
        self:showProgress(true)
      elseif code == Define.TerritoryPacketCode.SelfCamp then
        self:updateView(self.territoryData)
      end
    end)
    Me:playSoundByKey("g2055_clik_territoryButton")
  end
  
  function self.buttonGetAward.onMouseClick()
    Me:getTerritoryAward()
    Me:playSoundByKey("g2055_clik_territoryButton")
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.UPDATE_TERRITORY_OCCUPY_STATUS, function(territoryData)
    if self.territoryData.objID == territoryData.objID then
      self.territoryData = territoryData
      self:updateView(territoryData)
      self:progressFinish()
    end
  end)
end

function M:onClose()
  self:progressFinish()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function M:onOpen(param)
  self:init()
  param = param or {}
  self.territoryData = param
  self:updateView(param)
end

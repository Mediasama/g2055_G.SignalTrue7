local TerritoryConfig = T(Config, "TerritoryConfig")

function M:init()
  self.imageBackGround = self:child("ImageBackGround")
  self.imageAreaIcon = self:child("ImageAreaIcon")
  self.textGangName = self:child("TextGangName")
  self.textTipsGetAward = self:child("TextTipsGetAward")
  self.textTipsAward = self:child("TextTipsAward")
  self.textAwardNum = self:child("TextAwardNum")
  self.textTipsAward:setText(Lang:toText("area.tips.now.award"))
  self:initEvent()
  local instance = UI:isOpenWindow("UI/main/mobile_editor_joystick")
  if instance then
    self:setLevel(instance:getLevel() + 1)
  end
end

function M:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.UPDATE_TERRITORY_OCCUPY_STATUS, function(territoryData, cfgId)
    self:updateView(territoryData, cfgId)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.CLOSE_AREA_TIPS, function()
  end)
end

function M:updateView(data, cfgId)
  self.imageBackGround = self:child("ImageBackGround")
  local cfg = TerritoryConfig:getCfgById(cfgId)
  self.imageAreaIcon:setImage(cfg.area_icon)
  if data and data.awardCoin then
    self.textAwardNum:setText(data.awardCoin)
  end
  if data.owner then
    self.textGangName:setText(data.name)
    self.textTipsGetAward:setVisible(true)
    if data.owner == Me:getGangId() then
      self.imageBackGround:setImage("gameres|asset/Imageset/g2055_main:img_0_tips02")
      self.textTipsGetAward:setText(Lang:toText("area.tips.get.award"))
    else
      self.imageBackGround:setImage("gameres|asset/Imageset/g2055_main:img_0_tips01")
      self.textTipsGetAward:setText(Lang:toText("area.tips.rob.award"))
    end
  else
    self.textGangName:setText(Lang:toText("territory.ui.tips.unOccupied"))
    self.textTipsGetAward:setVisible(false)
    self.imageBackGround:setImage("gameres|asset/Imageset/g2055_main:img_0_tips03")
  end
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function M:onOpen(param)
  self:init()
  self:updateView(param, param.id)
end

local WinEntityHeadUI = M

function WinEntityHeadUI:init()
  self.textEntityName = self:child("TextEntityName")
  self.progress = self:child("Progress")
  self:setLevel(51)
end

function WinEntityHeadUI:updatePlayerBloodColor(value)
  if value then
    self.progress:setProperty("progress_lights_image", "gameres|asset/Imageset/g2055_main:pbar_0_health_04")
  else
    self.progress:setProperty("progress_lights_image", "gameres|asset/Imageset/g2055_main:pbar_0_health_02")
  end
end

function WinEntityHeadUI:onOpen(param)
  self.param = param
  self:init()
  self._allEvent = {}
  if param.isPlayer then
    self:updatePlayerBloodColor(param.hurtSelf)
    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_AUTO_HURT_SELF, function(value, objID)
      if self.param.objID == objID then
        self:updatePlayerBloodColor(value)
      end
    end)
  end
end

function WinEntityHeadUI:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinEntityHeadUI:checkWindowClose(data)
  if self.param == nil or self.param.objID == nil then
    return true
  end
  if data and data.progress and not data.progress.visible and data.name and data.name.visible then
    return true
  end
  return false
end

function WinEntityHeadUI:updateView(data)
  self.progress:setVisible(false)
  self.textEntityName:setVisible(false)
  if data.progress and data.progress.visible and data.progress.max ~= 0 then
    self.progress:setVisible(true)
    self.progress:setProgress(data.progress.min / data.progress.max)
  end
  if data.name and data.name.visible and data.name.value and data.name.value ~= "" then
    self.textEntityName:setVisible(true)
    self.textEntityName:setText(Lang.toText(data.name.value))
  end
end

function WinEntityHeadUI:onDataChanged(data)
  if self:checkWindowClose(data) then
    return false
  end
  self:updateView(data)
  return true
end

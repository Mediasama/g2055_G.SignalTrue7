function M:init()
  self.buttonApply = self:child("ButtonApply")
  
  self.imageApplied = self:child("ImageApplied")
  self.textGangName = self:child("TextGangName")
  self.buttonApply:setText(Lang:toText("gang.title.gang.apply"))
  
  function self.buttonApply.onMouseClick()
    Me:autoJoinOneGangClient(self.gangId, function(result)
      if result.code and result.code == Define.GangsPacketCode.SuccessApply then
        self:updateApplyStatus(true)
      end
    end)
  end
  
  self.updateApplyStatusListener = Lib.subscribeEvent(Event.EVENT_UPDATE_ALL_APPLY_BUTTON, function(result)
    if self.gangId and result and result[self.gangId] then
      self:updateApplyStatus(true)
    end
  end)
end

function M:updateApplyStatus(hasApplied)
  self.imageApplied:setVisible(hasApplied)
  self.buttonApply:setEnabled(not hasApplied)
end

function M:onDataChanged(data)
  data = data.data
  local gangName = data.name
  self.textGangName:setText(gangName)
  self:updateApplyStatus(data.applyList[Me.platformUserId] and not Lib.table_is_empty(data.applyList[Me.platformUserId]))
  self.gangId = data.gangId
end

function M:onDestroy()
  self.updateApplyStatusListener()
end

M:init()

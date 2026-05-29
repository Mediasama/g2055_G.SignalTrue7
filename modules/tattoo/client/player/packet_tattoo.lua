local handles = T(Player, "PackageHandlers")

function handles:onTattooTriggerOperation(packet)
  local tattooData = packet.tattooData
  local operateType = packet.operateType
  local objID = packet.objID
  if operateType == Define.TerritoryTriggerType.Enter then
    self:showTattooView(objID, tattooData)
  else
    self:hideTattooView(objID)
  end
end

function handles:onTattooInterrupt(packet)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("tattoo.tips.interrupt"))
  Lib.emitEvent(Event.EVENT_TATTOO_INTERRUPT)
end

function handles:onTattooSuccess(packet)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("tattoo.tips.success"))
  local data = {
    objID = packet.objID,
    data = packet.newTattooData
  }
  Lib.emitEvent(Event.EVENT_UPDATE_NEW_TATTOO_DATA, data)
end

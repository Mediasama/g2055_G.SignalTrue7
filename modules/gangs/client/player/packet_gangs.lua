local handles = T(Player, "PackageHandlers")

function handles:onUpdateGang(packet)
  self:setGang(packet.gang)
end

function handles:onUpdateApplyList(packet)
  self:updateApplyList(packet.applyList)
end

function handles:onNotifyApplyAccept(packet)
  self:notifyApplyAccept(packet)
  local str = Lang:getMessage("gang.tips.apply.gang.success")
  local text = string.format(str, self:getMyGangName())
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", text)
end

function handles:onUpdateBeChairMan(packet)
  self:updateBeChairMan(packet)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("gang.tips.replace.chairman"))
end

function handles:playerOutHome(packet)
  Lib.emitEvent(Event.EVENT_PLAYER_OUT_HOME)
end

function handles:updateToGang(packet)
  if packet then
    Lib.emitEvent(Event.EVENT_TOP_GANG_UPDATE, packet.data)
  end
end

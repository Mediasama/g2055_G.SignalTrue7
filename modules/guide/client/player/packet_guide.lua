local handles = T(Player, "PackageHandlers")

function handles:S2C_SendDoorPos(packet)
  local GuideHelper = T(Lib, "GuideHelper")
  GuideHelper:initDoorPosition(packet.position, packet.rotation, packet.isOldPlayer)
  GuideHelper:enterGuild()
end

function handles:finishGuide(packet)
  Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_OUT_DOOR)
end

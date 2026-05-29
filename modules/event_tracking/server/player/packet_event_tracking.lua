local handles = T(Player, "PackageHandlers")

function handles:onRecordClientNormalExit(packet)
  self:evt_recordClientNormalExit()
end

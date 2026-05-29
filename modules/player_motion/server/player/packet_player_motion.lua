local handles = T(Player, "PackageHandlers")

function handles:pam_C2S_RequestActiveMotion(packet)
  local motionId = packet.motionId
  self:pam_playMotion(motionId)
end

function handles:pam_C2S_RequestStopMotion(packet)
  self:pam_stopMotion()
end

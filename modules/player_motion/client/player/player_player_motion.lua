local PlayerMotionClient = Player
PlayerMotionClient.lastSelectMotionTab = nil

function PlayerMotionClient:pam_C2S_RequestActiveMotion(param, resp)
  local packet = param or {}
  packet.pid = "pam_C2S_RequestActiveMotion"
  self:sendPacket(packet, resp)
end

function PlayerMotionClient:pam_C2S_RequestStopMotion(param, resp)
  local packet = param or {}
  packet.pid = "pam_C2S_RequestStopMotion"
  self:sendPacket(packet, resp)
end

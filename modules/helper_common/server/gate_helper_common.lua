local HelperCommonServer = T(Lib, "HelperCommonServer")

function HelperCommonServer:export_play3DSoundByKey(key, position)
  local packet = {
    pid = "S2C_play3DSoundByKey",
    key = key,
    position = position
  }
  WorldServer.BroadcastPacket(packet)
end

return HelperCommonServer

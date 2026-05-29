local PlayerSceneTriggersServer = Player

function PlayerSceneTriggersServer:stg_S2C_ChangeBGM(bgm)
  local packet = {
    pid = "stg_S2C_ChangeBGM",
    bgm = bgm
  }
  self:sendPacket(packet)
end

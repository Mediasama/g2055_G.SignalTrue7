local Player = _ENV.Player
Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
  if info.objID ~= Me.objID then
    return
  end
  Me:evt_onPlayerLogin()
end)

function Player:evt_isLogin()
  return self.loginTime ~= nil
end

function Player:evt_onPlayerLogin()
  print("==================> Player:evt_onPlayerLogin() ", self.platformUserId)
  self.loginTime = os.time()
  if not World.isClient then
    self:setValue("battle_id", self.loginTime)
    local serverConfig = Server.CurServer:getConfig()
    local gameId = serverConfig.gameId
    self:setValue("game_id", gameId)
  end
end

function Player:evt_onPlayerLogout()
  if World.isClient then
  else
    self:evt_reportEvent("player_out", {player_out_type = 0})
  end
end

function Player:evt_recordClientNormalExit()
  self.clientNormalExit = true
end

function Player:getCurrentTotalGameTime()
  if self.loginTime then
    return os.time() - self.loginTime
  else
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Player:getCurrentTotalGameTime(),self.loginTime is nil ", self.platformUserId)
    return -1
  end
end

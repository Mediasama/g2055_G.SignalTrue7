local Player = _ENV.Player

function Player:playSoundOnClient(key)
  self:sendPacket({
    pid = "playSoundOnClient",
    key = key
  })
end

function Player:checkLoginFail()
  return self.loginFail
end

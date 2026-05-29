local Player = _ENV.Player

function Player:tryCarryPlayer(userId)
  self:sendPacket({
    pid = "onCarryPlayer",
    userId = userId
  })
end

function Player:tryThrowPlayer(userId)
  self:sendPacket({
    pid = "onThrowPlayer",
    userId = userId
  }, function(result)
    if result then
      Lib.emitEvent(Event.EVENT_CHARACTER_STATE_ON_GROUND_CARRY_SUCCESS, userId, false)
    end
  end)
end

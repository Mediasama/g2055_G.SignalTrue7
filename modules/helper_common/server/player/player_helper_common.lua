local Player = _ENV.Player

function Player:S2C_play3DSoundByKey(key, position)
  local packet = {
    pid = "S2C_play3DSoundByKey",
    key = key,
    position = position
  }
  self:sendPacket(packet)
end

function Player:S2C_play2DSoundByKey(key)
  local packet = {
    pid = "S2C_play2DSoundByKey",
    key = key
  }
  self:sendPacket(packet)
end

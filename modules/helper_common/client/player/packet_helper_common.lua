local SoundConfig = T(Config, "SoundConfig")
local handles = T(Player, "PackageHandlers")

function handles:S2C_play3DSoundByKey(packet)
  local key = packet.key or 0
  local position = packet.position or Vector3.new(0, 0, 0)
  local volume = packet.volume or 1
  self:play3DSoundByKey(key, position, volume)
end

function handles:S2C_play2DSoundByKey(packet)
  local key = packet.key or 0
  self:playSoundByKey(key)
end

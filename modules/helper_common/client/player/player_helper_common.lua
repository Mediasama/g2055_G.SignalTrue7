local SoundConfig = T(Config, "SoundConfig")
local Player = _ENV.Player

function Player:playSoundByKey(key)
  local cfg = SoundConfig:getSound(key)
  if not cfg then
    return nil
  end
  return self:playSound(cfg)
end

function Player:play3DSoundByKey(key, position, volume)
  local key = key or 0
  local position = position or Vector3.new(0, 0, 0)
  local volume = volume or 1
  local cfg = SoundConfig:getSound(key)
  if not cfg then
    return
  end
  local id = TdAudioEngine.Instance():play3dSound(cfg.sound, position, false, 1, 1.0, 100.0)
  TdAudioEngine.Instance():setSoundsVolume(id, volume)
end

function Player:playBgmByKey(key)
  if not key or key == self.curUiBgmKey then
    return
  end
  if self.curUiBgmSoundId then
    self:stopSound(self.curUiBgmSoundId)
    self:stopGameBgm()
  end
  self.curUiBgmSoundId = self:playSoundByKey(key)
  self.curUiBgmKey = key
end

function Player:stopBgm()
  local key
  if self.curUiBgmSoundId then
    self:stopSound(self.curUiBgmSoundId)
    self:stopGameBgm()
    self.curUiBgmSoundId = nil
    key = self.curUiBgmKey
    self.curUiBgmKey = nil
  end
  return key
end

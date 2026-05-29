local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:soundTimes(value)
  Lib.emitEvent(Event.EVENT_SOUND_TIME_CHANGE, value)
end

function Entity.ValueFunc:soundMoonCard(value)
  Lib.emitEvent(Event.EVENT_SOUND_MOON_CHANGE, value)
end

function Entity.ValueFunc:freeSoundTimes(value)
  Lib.emitEvent(Event.EVENT_FREE_SOUND_TIME_CHANGE, value)
end

local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:playerPassCardQuest(value)
  Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_UPDATE)
end

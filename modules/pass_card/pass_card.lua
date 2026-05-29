require("common.entity_pass_card")
require("common.entity_pass_card_quest")
require("common.event_pass_card")
require("common.config.pass_card_config")
require("common.config.pass_card_quest_config")
require("common.define_pass_card")
require("common.pass_card_helper")
if World.isClient then
  require("client.player.player_pass_card")
  require("client.player.packet_pass_card")
  require("client.entity.entity_pass_card")
  require("client.entity.entity_value_func_pass_card")
  require("client.gm_pass_card")
else
  require("server.player.player_pass_card")
  require("server.player.packet_pass_card")
  require("server.entity.entity_pass_card")
  require("server.gm_pass_card")
  require("server.pass_card_quest_helper")
end
local handlers = {}

function handlers.closePassCardWin()
  UI:closeWindow("./UI/pass_card/win_pass_card")
  UI:closeWindow("./UI/pass_card/win_pass_card_dialog_box")
end

function handlers.OnPlayerLogin(player)
  if player and player:isValid() then
    player:initPlayerPassCardDate()
    player:checkPlayerPassCard()
    player:checkPlayerPassCardQuest()
  end
end

Lib.subscribeEvent(Event.EVENT_PLAYER_ENTER_DYING, function(objID, obj)
  if obj and obj:isValid() and obj.isPlayer then
    obj:sendPacket({
      pid = "passCardPlayerDyingS2C"
    })
  end
end)
Lib.subscribeEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, function(questType, subType, objId, num)
  local obj = World.CurWorld:getEntity(objId)
  if obj and obj:isValid() and obj.isPlayer then
    obj:updatePassCardQuest(questType, subType, num)
  end
end)
Lib.subscribeEvent(Event.EVENT_ENTITY_DEATH, function(objID, obj)
  if obj and obj:isValid() and obj.isPlayer then
    obj:sendPacket({
      pid = "passCardPlayerDyingS2C"
    })
  end
end)
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

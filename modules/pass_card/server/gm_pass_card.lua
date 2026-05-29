local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\135\187\230\157\128\231\142\169\229\174\182"] = function(self)
  local player = Game.GetPlayerByUserId(18512)
  if player and player:isValid() then
    Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypeKill, Define.PassCardQuestKillType.QuestKillPlayer, player.objID, 1)
  end
end

local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\133\179\233\151\173\230\129\162\229\164\141\230\137\128\230\156\137ui\229\136\155\229\187\186"] = function()
  Lib.switchDebugCloserUI()
end
GMItem["game_common/\230\181\139\232\175\149\229\140\185\233\133\141\230\136\144\229\138\159"] = function()
  local data = {
    {
      userId = 18560,
      info = {}
    },
    {
      userId = 18544,
      info = {}
    },
    {
      userId = 18528,
      info = {}
    },
    {
      userId = 18512,
      info = {}
    }
  }
  Lib.emitEvent(Event.EVENT_MATCH_SUCCESS, data)
end

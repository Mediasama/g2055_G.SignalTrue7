local GuideHelper = T(Lib, "GuideHelper")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\228\184\128\228\184\170npc"] = function(self)
  local pos = self:getPosition()
  pos.x = pos.x + 1
  pos.z = pos.z + 1
  GuideHelper:crateEnemy(pos)
end

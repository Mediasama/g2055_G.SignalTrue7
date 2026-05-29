local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\231\187\152\229\136\182\229\140\133\228\184\186\229\187\186\231\173\145\230\191\128\229\133\137"] = function(self)
  self:drawBoxLaser()
end

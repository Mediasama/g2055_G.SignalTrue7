local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\128\146\229\156\176\231\138\182\230\128\129"] = function(self)
  self:changeHp(-self:getCurHp())
end
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\143\150\230\182\136\229\128\146\229\156\176\231\138\182\230\128\129"] = function(self)
end

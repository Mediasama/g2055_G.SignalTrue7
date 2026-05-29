local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\232\142\183\229\190\15110\228\184\170\229\129\183\232\189\166\233\129\147\229\133\183"] = function(self)
  local params = {num = 10}
  Me:sendPacket({
    pid = "changeUnlockCarItemNum",
    params = params
  })
end
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\136\155\229\187\186\232\183\145\232\189\166"] = GM:inputStr(function(self, value)
  local amount = tonumber(value) or 60021
  Me:sendPacket({
    pid = "createVehicle",
    params = {id = amount}
  })
end, function(self)
  return "60021"
end)
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\188\128\232\189\166"] = GM:inputStr(function(self, value)
  local amount = tonumber(value) or 60021
  Me:sendPacket({
    pid = "createAndRideVehicle",
    params = {id = amount}
  })
end, function(self)
  return "60021"
end)
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\230\181\139\232\175\149\229\133\179\233\151\173\231\170\151\229\143\163"] = function(self)
  Lib.closeWindow("./UI/territory/win_territory")
end

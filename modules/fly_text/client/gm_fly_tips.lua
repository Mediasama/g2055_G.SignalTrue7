local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2055/\231\179\187\231\187\159tips"] = function()
  local content = "{}" .. os.time()
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", content)
end
GMItem["g2055/\229\183\166\228\184\138\230\150\185tips"] = function()
  local content = "{}" .. os.time()
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalBattleTips", content)
end

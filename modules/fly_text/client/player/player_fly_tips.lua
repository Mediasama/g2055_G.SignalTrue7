local Player = _ENV.Player
local handles = T(Player, "PackageHandlers")

function handles:clientAddOneNewFlyTexts(packet)
  local content = Lang:toText(packet.content)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", content)
end

function handles:clientAddOneNewBattleTips(packet)
  local content = packet.content
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalBattleTips", content)
end

local FlyTipsHelper, BattleTipsHelper, FlyTextHelper
if World.isClient then
  require("client.player.player_fly_tips")
  FlyTipsHelper = require("client.fly_tips_helper")
  BattleTipsHelper = require("client.battle_tips_helper")
  require("client.fly_text_helper")
  FlyTextHelper = T(Lib, "FlyTextHelper")
  require("client.gm_fly_tips")
else
end
local handlers = {}

function handlers.pushNormalFlyText(content)
  local itemInfo = {type = 1, content = content}
  FlyTipsHelper:pushOneFlyTipsItem(itemInfo)
end

function handlers.pushNormalBattleTips(content)
  local itemInfo = {type = 1, content = content}
  BattleTipsHelper:pushOneFlyTipsItem(itemInfo)
end

function handlers.flyUIBlood(text)
  text = tostring(text)
  local scale = World.cfg.BloodTipsSetting.endScale
  FlyTextHelper:onShowUIFlyText(nil, text, scale)
end

function handlers.flySceneBlood(part, atlas, text, scale)
  text = tostring(text)
  FlyTextHelper:onShowEntityFlyText(part, atlas, text, scale)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  handlers[name](...)
end

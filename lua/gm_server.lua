local GMItem = GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\231\169\186"] = function(self)
end

GMItem["Hacks/Infinite Money"] = function(self)
    self:addCurrencyById(3, 99999999, "GM")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "Money added!")
end

return GMItem

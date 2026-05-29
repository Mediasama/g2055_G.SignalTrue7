local handles = T(Player, "PackageHandlers")

function handles:passCardLevelUpS2C(packet)
  Lib.emitEvent(Event.EVENT_PASS_CARD_LEVEL_UP)
end

function handles:passCardAddExpS2C(packet)
  Lib.emitEvent(Event.EVENT_PASS_CARD_ADD_EXP)
end

function handles:buyPassGoldCardResultS2C(packet)
  Client.ShowTip(1, Lang:toText(packet.isSucceed and "passCard.buy.success" or "passCard.buy.fail"), 40)
  if packet and packet.isSucceed then
    Lib.emitEvent(Event.EVENT_PASS_CARD_BUY_GOLD_CARD)
  end
end

function handles:buyPassCardLevelUpResultS2C(packet)
  Client.ShowTip(1, Lang:toText(packet.isSucceed and "passCard.buy.success" or "passCard.buy.fail"), 40)
end

function handles:passCardGetRewardResultS2C(packet)
  Lib.emitEvent(Event.EVENT_PASS_CARD_GET_REWARD)
end

function handles:passCardPlayerDyingS2C(packet)
  Plugins.CallTargetPluginFunc("pass_card", "closePassCardWin")
end

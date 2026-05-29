local handles = T(Player, "PackageHandlers")
local ExchangeConfig = T(Config, "ExchangeConfig")

function handles:ExchangeMoney(packet)
  if not packet or not packet.idx then
    return
  end
  local cfg = ExchangeConfig:getCfgByIndex(packet.idx)
  if not cfg then
    return
  end
  Lib.payMoneyCube(self, 10100 + packet.idx, 0, cfg.cost, function(success)
    self:sendPacket({
      pid = "ExchangeMoneyResult",
      isSucceed = success
    })
    if success then
      self:addCurrencyByName(Define.CURRENCY_TYPE.gold, cfg.num, Define.CurrencyReason.Exchange, Define.CurrencyType.FromSystem)
    end
  end, 1, Define.ExchangeItemsReason.BuyShop)
end

Lib.subscribeEvent(Event.EVENT_PAY_MONEY_SUCCESS, function(player)
  if player and player:isValid() then
    player:sendPacket({
      pid = "CubeNumChanged"
    })
  end
end)

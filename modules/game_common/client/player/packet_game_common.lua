local handles = T(Player, "PackageHandlers")

function handles:playSoundOnClient(packet)
  Me:playSoundByKey(packet.key)
end

function handles:ExchangeMoneyResult(packet)
  if not packet.isSucceed then
    Interface.onRecharge(1)
  end
  Client.ShowTip(1, Lang:toText(packet.isSucceed and "exchange.buy.success" or "exchange.buy.fail"), 40)
end

function handles:CubeNumChanged(packet)
  Lib.emitEvent(Event.CUBE_NUM_CHANGE)
end

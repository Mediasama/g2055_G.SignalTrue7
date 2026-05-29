local handles = T(Player, "PackageHandlers")

function handles:syncPlayerData(packet)
  Lib.emitEvent(Event.EVENT_CHANGE_HP, packet.data.hp, packet.data.maxHp)
end

function handles:onBattleStart(packet)
  print("handles:onBattleStart")
  if not packet.isSuccess then
    print("\229\140\185\233\133\141\229\164\177\232\180\165\239\188\140\228\186\186\230\149\176\228\184\141\232\182\179")
    local FlyTipsHelper = T(Lib, "FlyTipsHelper")
    FlyTipsHelper:pushNormalFlyTipsItem("\229\140\185\233\133\141\229\164\177\232\180\165\239\188\140\228\186\186\230\149\176\228\184\141\232\182\179")
  end
end

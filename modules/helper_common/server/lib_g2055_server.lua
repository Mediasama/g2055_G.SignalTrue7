local Lib = _ENV.Lib

function Lib.payMoneyCube(player, uniqueId, coinId, price, callback, goodsNum, reason)
  Lib.payMoney(player, uniqueId, coinId, price, function(success)
    callback(success)
    if success then
      Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypePay, Define.PassCardQuestPayType.QuestPayCube, player.objID, price)
    end
  end, goodsNum, reason)
end

local Player = _ENV.Player

function Player:addCurrencyByName(name, amount, reason, currency_type)
  if not name then
    return
  end
  if not amount or amount <= 0 then
    return
  end
  name = Coin:getEnvCoinName(name)
  local currency_before = self:getCurrencyByName(name)
  if name == Define.CURRENCY_TYPE.gold then
    local config = World.cfg.bastionSetting or {}
    local vault = config.vault or {}
    local maxBalance = vault.maxBalance or 99999999
    if currency_before >= maxBalance then
      return
    elseif maxBalance < currency_before + amount then
      amount = maxBalance - currency_before
    end
  end
  self:addCurrency(name, amount, reason)
  self:evt_reportCoinChange(amount, currency_before, Define.CurrencyReasonId[reason], Coin:getCoinId(name), currency_type)
  if name == Define.CURRENCY_TYPE.gold and reason ~= Define.CurrencyReason.PassCardReward and reason ~= Define.CurrencyReason.BastionFetch then
    Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypeInCome, Define.PassCardQuestInComeType.QuestInComeMoney, self.objID, amount)
  end
  return true
end

function Player:addCurrencyById(coinId, amount, reason, currency_type)
  local name = Coin:coinNameByCoinId(coinId)
  if not name then
    Lib.error("can not find currency name with type", type)
    return
  end
  return self:addCurrencyByName(name, amount, reason, currency_type)
end

local payCurrencyOld = Player.payCurrency

function Player:payCurrencyByName(coinName, count, reason, resultCb, clear, check, related)
  if not self:checkCurrencyEnoughByName(coinName, count) then
    if resultCb then
      resultCb(false)
    end
    return false
  end
  local currency_before = self:getCurrencyByName(coinName)
  coinName = Coin:getEnvCoinName(coinName)
  if not World.cfg.useFDiamond and coinName == Define.CURRENCY_TYPE.gold_cube then
    self:doConsumeDiamonds(coinName, count, function(ret)
      if resultCb then
        resultCb(ret)
        if ret then
        end
      end
    end, nil)
    return false
  end
  local ret = payCurrencyOld(self, coinName, count, clear, check, reason, related)
  if resultCb then
    resultCb(ret)
  end
  if ret then
  end
  if ret then
    if coinName == Define.CURRENCY_TYPE.gold and reason ~= Define.CurrencyReason.BastionDeposit then
      Lib.emitEvent(Event.EVENT_PASS_CARD_QUEST_BEHAVIOUR, Define.PassCardQuestType.QuestTypePay, Define.PassCardQuestPayType.QuestPayMoney, self.objID, count)
    end
    self:evt_reportCoinChange(count, currency_before, Define.CurrencyReasonId[reason], Coin:getCoinId(coinName), -1)
  end
  return ret
end

function Player:payCurrencyById(coinId, count, reason, resultCb)
  local name = Coin:coinNameByCoinId(coinId)
  if not name then
    Lib.error("can not find currency name with type", coinId)
    return
  end
  return self:payCurrencyByName(name, count, reason, resultCb, nil, false, nil)
end

function Player:doConsumeDiamonds(coinName, price, callBack, uniqueId)
  self:consumeDiamonds(coinName, price, function(ret)
    if not self or not self:isValid() then
      callBack(false)
      return
    end
    callBack(ret)
  end, uniqueId)
end

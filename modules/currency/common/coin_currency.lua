local Coin = _ENV.Coin

function Coin:getCoinIdByName(coinName)
  local ret = self:getCoinId(coinName)
  if not ret then
    coinName = self:getEnvCoinName(coinName)
    local cfg = self.coinMapping[coinName]
    ret = cfg and cfg.coinId
  end
  return ret
end

local getCoinId = Coin.getCoinId

function Coin:getCoinId(coinName)
  coinName = self:getEnvCoinName(coinName)
  return getCoinId(self, coinName)
end

local coinNameByCoinIdOld = Coin.coinNameByCoinId

function Coin:coinNameByCoinId(coinId)
  if coinId == 0 and World.cfg.useFDiamond then
    return Define.CURRENCY_TYPE.fDiamonds
  end
  return coinNameByCoinIdOld(self, coinId)
end

function Coin:getCoinImg(id)
  local name = self:coinNameByCoinId(id)
  if self.coinMapping[name] then
    return self.coinMapping[name].icon
  end
  return Coin:iconByCoinName(name)
end

function Coin:getEnvCoinName(_coinName)
  local coinName = _coinName
  if _coinName == "gDiamonds" and World.cfg.useFDiamond then
    coinName = Define.CURRENCY_TYPE.fDiamonds
  end
  return coinName
end

function Coin:getCoinNumById(obj, id)
  local coinName = self:coinNameByCoinId(id)
  return self:getCoinNumByName(obj, coinName)
end

function Coin:getCoinNumByName(obj, _coinName)
  local wallet = obj:data("wallet")
  local coinName = self:getEnvCoinName(_coinName)
  local coinNum = 0
  if wallet[coinName] then
    coinNum = wallet[coinName].count or 0
  end
  return math.floor(coinNum)
end

function Coin:getCoinLang(id)
  return Lang:toText(string.format("currency.%d", id))
end

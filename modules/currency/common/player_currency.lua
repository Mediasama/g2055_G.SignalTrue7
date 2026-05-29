local Player = _ENV.Player

function Player:getCurrencyById(id)
  return Coin:getCoinNumById(self, id)
end

function Player:getCurrencyByName(name)
  return Coin:getCoinNumByName(self, name)
end

function Player:checkCurrencyEnoughById(id, count)
  return count <= self:getCurrencyById(id)
end

function Player:checkCurrencyEnoughByName(name, count)
  return count <= self:getCurrencyByName(name)
end

local Player = _ENV.Player

function Player:addOccupyAward(amount, id)
  self:addCurrencyByName(Define.CURRENCY_TYPE.gold, amount, Define.CurrencyReason.OccupyTerritory, Define.CurrencyType.FromSystem)
  self:sendPacket({
    pid = "onOccupyGetAward",
    id = id,
    amount = amount
  })
end

function Player:notifyOccupySuccess(id, territoryData)
  self:sendPacket({
    pid = "onOccupySuccess",
    id = id,
    territoryData = territoryData
  })
end

function Player:updateOccupyInfo(id, occupyInfo)
  self:sendPacket({
    pid = "onUpdateTerritoryOccupyInfo",
    id = id,
    occupyInfo = occupyInfo
  })
end

function Player:interruptTerritoryOccupy(objID)
  self:sendPacket({
    pid = "onInterruptTerritoryOccupy",
    objID = objID
  })
end

function Player:notifyTerritorySwitchOwner(name, type, territoryName, enterGang)
  self:sendPacket({
    pid = "onNotifyTerritorySwitchOwner",
    name = name,
    type = type,
    territoryName = territoryName,
    enterGang = enterGang
  })
end

function Player:setPlayerOccupyBuff(add)
  if add then
    self:addBuff("myplugin/territory_occupy")
  else
    self:removeTypeBuff("fullName", "myplugin/territory_occupy")
  end
end

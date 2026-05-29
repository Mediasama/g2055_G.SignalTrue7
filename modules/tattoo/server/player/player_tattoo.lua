local Player = _ENV.Player

function Player:interruptTattoo(objID)
  self:sendPacket({
    pid = "onTattooInterrupt",
    objID = objID
  })
end

function Player:tattooSuccess(data)
  self:sendPacket({
    pid = "onTattooSuccess",
    objID = data.objID,
    tattooId = data.successTattooId,
    newTattooData = data.newTattooData
  })
end

local Player = _ENV.Player

function Player:getCurCarId()
  local useCarInfo = self:getInUseCar()
  if not useCarInfo then
    return nil
  else
    return useCarInfo.id
  end
end

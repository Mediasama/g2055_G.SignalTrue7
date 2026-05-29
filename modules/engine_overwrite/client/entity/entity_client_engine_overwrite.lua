local EntityClient = _ENV.EntityClient

function EntityClient:updateMainPlayerRideOn()
  local player = Player.CurPlayer
  local target = World.CurWorld:getEntity(player.rideOnId)
  PlayerControl.UpdateControlInfo(target)
  PlayerControl.UpdatePersonView()
end

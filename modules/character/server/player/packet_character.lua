local handles = T(Player, "PackageHandlers")

function handles:ChangeViewMode(packet)
  self:setProp("calcYawBySpeedDir", packet.mode == 1 and 0 or 1)
end

function handles:changeState2s(packet)
  self:changeState(packet.state, packet.param)
end

function handles:sendBeginMoveSpeed(packet)
  self.oldMoveSpeed = self.weapon.moveSpeed
  self.oldMoveAcc = self.weapon.moveAcc
  self:setProp("moveSpeed", packet.moveSpeed)
  self:setProp("moveAcc", packet.moveAcc)
end

function handles:resetMoveSpeed(packet)
  self:setProp("moveSpeed", self.oldMoveSpeed)
  self:setProp("moveAcc", self.oldMoveAcc)
end

function handles:sendRechargeFull(packet)
  local p = {
    pid = "showRechargeFull",
    objID = self.objID,
    chargeAction = packet.chargeAction
  }
  self:broadcastDungeonPacket(p)
end

function handles:resetRecharge(packet)
  local p = {
    pid = "hideRechargeFull",
    objID = self.objID
  }
  self:broadcastDungeonPacket(p)
end

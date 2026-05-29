local handles = T(Player, "PackageHandlers")

function handles:ConnectorMsgReceive(packet)
  Lib.emitEvent(Event.EVENT_CONNECTOR_MSG_RECEIVE, packet.data)
end

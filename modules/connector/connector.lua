require("common.i_connector_filter")
if World.isClient then
  require("client.gm_connector")
  require("client.connector_center")
  require("client.connector_player_packet")
else
  require("server.gm_connector")
  require("server.connector_center")
end
local handlers = {}
if World.isClient then
  function handlers.start()
    local CConnectorCenter = T(Lib, "ConnectorCenter")
    
    CConnectorCenter:start()
  end
else
  function handlers.start()
    local SConnectorCenter = T(Lib, "ConnectorCenter")
    
    SConnectorCenter:start()
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end

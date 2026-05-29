require("client.connector_event")
require("client.connector_dispatch")
require("common.i_connector_center")
local v_type = type
local CConnectorCenter = T(Lib, "ConnectorCenter")
local cjson = require("cjson")

function CConnectorCenter:start()
  Lib.subscribeEvent(Event.EVENT_CONNECTOR_MSG_RECEIVE, function(param)
    local type = param.type
    local data = param.data
    local targets = param.targets
    local success, result = pcall(cjson.decode, data or "{}")
    if success then
      self:onMsgReceive(type, targets, result)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CONNECTOR_MSG, function(data)
    self:sendMsg(data.type, data.data)
  end)
end

function CConnectorCenter:sendMsg(type, data)
  if v_type(data) == "table" then
    data = cjson.encode(data)
  end
  Me:sendPacket({
    pid = "ConnectorMsg",
    data = {
      userId = Me.platformUserId,
      type = type,
      data = data
    }
  })
end

CConnectorCenter:start()

local IConnectorDispatch = class("ConnectorDispatch")
local cjson = require("cjson")
local v_type = type

function IConnectorDispatch:ctor()
  self.isDebug = false
  self.connectorMsgFuncList = {}
end

function IConnectorDispatch:onMsgReceive(type, targets, data)
  if self.isDebug then
    Lib.logInfo("[IConnectorDispatch:onMsgReceive] type=" .. type)
    Lib.logInfo("[IConnectorDispatch:onMsgReceive] targets=" .. Lib.v2s(targets))
    if v_type(data) == "string" then
      Lib.logInfo("[IConnectorDispatch:onMsgReceive] data=" .. data)
    else
      Lib.logInfo("[IConnectorDispatch:onMsgReceive] data=" .. cjson.encode(data))
    end
  end
  local isIntercept = false
  local funcList = self.connectorMsgFuncList[type]
  if funcList then
    for _, funcData in pairs(funcList) do
      isIntercept = funcData.func(table.unpack(funcData.params), type, targets, data) or isIntercept
    end
  end
  return isIntercept
end

function IConnectorDispatch:registerFunc(type, func, ...)
  self.connectorMsgFuncList[type] = self.connectorMsgFuncList[type] or {}
  local funcList = self.connectorMsgFuncList[type]
  table.insert(funcList, {
    func = func,
    params = {
      ...
    }
  })
end

return IConnectorDispatch

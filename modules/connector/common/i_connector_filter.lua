local ConnectorFilter = T(Lib, "ConnectorFilter")

function ConnectorFilter:init()
  self.isDebug = false
  self.connectorSendMsgFilterFuncList = {}
end

function ConnectorFilter:onSendMsgFilter(type, userId, data)
  local isIntercept = false
  local funcList = self.connectorSendMsgFilterFuncList[type]
  if funcList then
    for _, funcData in pairs(funcList) do
      isIntercept = funcData.func(table.unpack(funcData.params), type, {userId}, data) or isIntercept
    end
  end
  return isIntercept
end

function ConnectorFilter:registerSendMsgFilterFunc(type, func, ...)
  self.connectorSendMsgFilterFuncList[type] = self.connectorSendMsgFilterFuncList[type] or {}
  local funcList = self.connectorSendMsgFilterFuncList[type]
  table.insert(funcList, {
    func = func,
    params = {
      ...
    }
  })
end

ConnectorFilter:init()

local DoorsConfig = T(Config, "DoorsConfig")
local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorToolkit = Lib.class("BastionOperatorToolkit", BastionOperatorBase)

function BastionOperatorToolkit:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.ToolKit
end

function BastionOperatorToolkit:operate(param)
  local result = {}
  local ownerId = param.ownerId
  local owner = Game.GetPlayerByUserId(ownerId)
  if not owner or not owner:isValid() then
    result.status = Define.Bastion.Facility.OperateErrorCode.InvalidOwner
    result.msg = "InvalidOwner userId:" .. (ownerId or "unknown")
    return result
  end
  local operatorId = param.operatorId
  local operator = Game.GetPlayerByUserId(operatorId)
  if not operator or not operator:isValid() then
    result.status = Define.Bastion.Facility.OperateErrorCode.InvalidOperator
    result.msg = "InvalidOperator userId:" .. (operatorId or "unknown")
    return result
  end
  local manner = param.manner
  if manner == Define.Bastion.Facility.OperateType.Query then
    return self:query(param)
  elseif manner == Define.Bastion.Facility.OperateType.Deposit then
    return self:deposit(param)
  elseif manner == Define.Bastion.Facility.OperateType.Fetch then
    return self:fetch(param)
  elseif manner == Define.Bastion.Facility.OperateType.Steal then
    return self:steal(param)
  else
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.UnknownManner
    result.msg = "unknown manner:" .. (manner or "unknown")
    return result
  end
end

function BastionOperatorToolkit:query(param)
  local requestData = param.requestData or {}
  local type = requestData.type or Define.Bastion.Defense.Type.Door
  local result = {}
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local data = {}
  data.door = owner:getBastionDefenseItem(type)
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = data
  return result
end

function BastionOperatorToolkit:deposit(param)
end

function BastionOperatorToolkit:fetch(param)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local requestData = param.requestData or {}
  local id = requestData.id or 0
  local type = requestData.type or Define.Bastion.Defense.Type.Door
  if param.ownerId ~= param.operatorId then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "can not fetch others defense"
    return result
  end
  local configItem = DoorsConfig:getCfgById(id)
  if not configItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.toolkit.fetch.no.select.item"
    return result
  end
  local price = configItem.price
  if price > operator:getCurrencyById(Define.Bastion.Currency.Type.Gold) then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.toolkit.fetch.no.enough.money"
    return result
  end
  if not operator:canChangeBastionDefense(type) then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.toolkit.fetch.wrong.status"
    return result
  end
  operator:payCurrencyById(Define.Bastion.Currency.Type.Gold, price, Define.CurrencyReason.Door)
  operator:changeBastionDefense(type, id)
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Defense.Fetch)
  local data = {}
  data.door = operator:getBastionDefenseItem(type)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = data
  return result
end

function BastionOperatorToolkit:steal(param)
end

return BastionOperatorToolkit

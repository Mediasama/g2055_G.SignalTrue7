local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorVault = Lib.class("BastionOperatorVault", BastionOperatorBase)

function BastionOperatorVault:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.Vault
end

function BastionOperatorVault:operate(param)
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

function BastionOperatorVault:query(param)
  local result = {}
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  local data = {}
  data.balance = owner:getBastionCurrency(Define.Bastion.Currency.Type.Gold)
  data.cash = operator:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = data
  return result
end

function BastionOperatorVault:deposit(param)
  local result = {}
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local data = param.requestData or {}
  local delta = data.delta or 0
  if delta <= 0 then
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.vault.manner.deposit.error.no.money"
    return result
  end
  local overflowed = false
  local config = World.cfg.bastionSetting or {}
  local vault = config.vault or {}
  local maxBalance = vault.maxBalance
  local currentBalance = owner:getBastionCurrency(Define.Bastion.Currency.Type.Gold)
  if maxBalance < currentBalance + delta then
    delta = maxBalance - currentBalance
    overflowed = true
  end
  local cash = operator:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if delta > cash then
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.vault.manner.deposit.error.no.money"
    return result
  end
  operator:payCurrencyById(Define.Bastion.Currency.Type.Gold, delta, Define.CurrencyReason.BastionDeposit)
  owner:addBastionCurrency(Define.Bastion.Currency.Type.Gold, delta)
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Vault.Deposit)
  local data = {}
  data.balance = owner:getBastionCurrency(Define.Bastion.Currency.Type.Gold)
  data.cash = operator:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  if overflowed then
    result.status = Define.Bastion.Facility.OperateErrorCode.Overflow
    result.msg = "bastion.vault.manner.deposit.error.overflow"
  end
  result.data = data
  return result
end

function BastionOperatorVault:fetch(param)
  local result = {}
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local requestData = param.requestData or {}
  local delta = requestData.delta or 0
  if delta <= 0 then
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.vault.manner.deposit.error.no.money"
    return result
  end
  local balance = owner:getBastionCurrency(Define.Bastion.Currency.Type.Gold)
  if delta > balance then
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.vault.manner.deposit.error.no.money"
    return result
  end
  local config = World.cfg.bastionSetting or {}
  local vault = config.vault or {}
  local maxBalance = vault.maxBalance
  local curPlayerMoney = operator:getCurrencyByName(Define.CURRENCY_TYPE.gold)
  if maxBalance < curPlayerMoney + delta then
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.vault.manner.deposit.error.overflow"
    return result
  end
  owner:payBastionCurrency(Define.Bastion.Currency.Type.Gold, delta)
  local reason = param.ownerId == param.operatorId and Define.CurrencyReason.BastionFetch or Define.CurrencyReason.BastionSteal
  local type = param.ownerId == param.operatorId and Define.CurrencyType.Others or Define.CurrencyType.FromPlayer
  operator:addCurrencyById(Define.Bastion.Currency.Type.Gold, delta, reason, type)
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Vault.Fetch)
  local data = {}
  data.balance = owner:getBastionCurrency(Define.Bastion.Currency.Type.Gold)
  data.cash = operator:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = data
  return result
end

function BastionOperatorVault:steal(param)
  return self:fetch(param)
end

return BastionOperatorVault

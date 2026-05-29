local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_vault = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBastion = Entity

function EntityBastion:getBastionVault()
  return self:getValue("bastion_vault") or {}
end

function EntityBastion:setBastionVault(value)
  self:setValue("bastion_vault", value)
end

function EntityBastion:getBastionCurrencyDict()
  local vault = self:getBastionVault()
  return vault.currencyDict or {}
end

function EntityBastion:setBastionCurrencyDict(dict)
  local vault = self:getBastionVault()
  vault.currencyDict = dict
  self:setBastionVault(vault)
end

function EntityBastion:getBastionCurrency(id)
  local currencyDict = self:getBastionCurrencyDict()
  return currencyDict[id] or 0
end

function EntityBastion:setBastionCurrency(id, amount)
  local currencyDict = self:getBastionCurrencyDict()
  currencyDict[id] = math.max(0, amount)
  self:setBastionCurrencyDict(currencyDict)
end

function EntityBastion:changeBastionCurrency(id, delta)
  local amount = self:getBastionCurrency(id)
  self:setBastionCurrency(id, amount + delta)
end

function EntityBastion:addBastionCurrency(id, delta)
  self:changeBastionCurrency(id, delta)
end

function EntityBastion:payBastionCurrency(id, delta)
  self:changeBastionCurrency(id, -delta)
end

function EntityBastion:getBastionVaultCreateTime()
  local vault = self:getBastionVault()
  return vault.createTime or 0
end

function EntityBastion:setBastionVaultCreateTime(time)
  local vault = self:getBastionVault()
  vault.createTime = time
  self:setBastionVault(vault)
end

local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_defense = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBastion = Entity

function EntityBastion:getBastionDefense()
  return self:getValue("bastion_defense") or {}
end

function EntityBastion:setBastionDefense(value)
  self:setValue("bastion_defense", value)
end

function EntityBastion:getBastionDefenseDict()
  local defense = self:getBastionDefense()
  return defense.defenseDict or {}
end

function EntityBastion:setBastionDefenseDict(dict)
  local defense = self:getBastionDefense()
  defense.defenseDict = dict
  self:setBastionDefense(defense)
end

function EntityBastion:getBastionDefenseItem(type)
  local defenseDict = self:getBastionDefenseDict()
  return defenseDict[type]
end

function EntityBastion:setBastionDefenseItem(type, item)
  local defenseDict = self:getBastionDefenseDict()
  defenseDict[type] = item
  self:setBastionDefenseDict(defenseDict)
end

function EntityBastion:getBastionDefenseCreateTime()
  local vault = self:getBastionDefense()
  return vault.createTime or 0
end

function EntityBastion:setBastionDefenseCreateTime(time)
  local defense = self:getBastionDefense()
  defense.createTime = time
  self:setBastionDefense(defense)
end

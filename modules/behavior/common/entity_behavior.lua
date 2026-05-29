local BehaviorManager = require("common.behavior_manager")
local ValueDef = T(Entity, "ValueDef")
ValueDef.stateMask = {
  false,
  false,
  true,
  true,
  {},
  false
}
local EntityBehavior = Entity

function EntityBehavior:getStateMask()
  return self:getValue("stateMask")
end

function EntityBehavior:setStateMask(value)
  self:setValue("stateMask", value)
end

function EntityBehavior:getStateMaskWithKey(key)
  local dict = self:getStateMask()
  return dict[key] or 0
end

function EntityBehavior:setStateMaskWithKey(key, value)
  local dict = self:getStateMask() or {}
  dict[key] = value
  self:setStateMask(dict)
end

function EntityBehavior:isStateMaskMatch(KVList)
  local compareFunc = {
    ["=="] = function(a, b)
      return a == b
    end,
    [">="] = function(a, b)
      return b <= a
    end,
    [">"] = function(a, b)
      return b < a
    end,
    ["<="] = function(a, b)
      return a <= b
    end,
    ["<"] = function(a, b)
      return a < b
    end,
    ["~="] = function(a, b)
      return a ~= b
    end,
    ["!="] = function(a, b)
      return a ~= b
    end
  }
  for key, param in pairs(KVList) do
    local a = self:getStateMaskWithKey(key)
    local b = param.value
    local compare = compareFunc[param.compare]
    if not compare then
      return false
    end
    if not compare(a, b) then
      return false
    end
  end
  return true
end

function EntityBehavior:getUnitLocator()
  local locator = {
    type = Define.Unit.Type.Entity,
    id = self.objID
  }
  return locator
end

function EntityBehavior:getOperationConfig()
  local operationConfig = self:cfg().operationConfig or {}
  return operationConfig
end

function EntityBehavior:getOperationList(type)
  local operationConfig = self:getOperationConfig()
  return operationConfig[type] or {}
end

function EntityBehavior:isRunningBehavior()
  local behaviorList = BehaviorManager.Instance():getBehaviorList(self:getUnitLocator())
  for i, behavior in pairs(behaviorList) do
    if behavior:getState() == Define.Behavior.State.Running then
      return true
    end
  end
  return false
end

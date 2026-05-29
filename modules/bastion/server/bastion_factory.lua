local BastionHome = require("server.bastion_home")
local BastionFactory = Lib.class("BastionFactory")
local _instance

function BastionFactory.Instance()
  if _instance == nil then
    _instance = BastionFactory.new()
    _instance:init()
  end
  return _instance
end

function BastionFactory:ctor()
  self._creatorDict = {}
end

function BastionFactory:destroy()
end

function BastionFactory:init()
  self:registerCreator(Define.Bastion.Type.Home, BastionHome)
end

function BastionFactory:registerCreator(type, class)
  self._creatorDict[type] = class
end

function BastionFactory:getCreator(type)
  return self._creatorDict[type]
end

function BastionFactory:create(param)
  local instance
  if not param then
    return instance
  end
  local type = param.type
  if not type then
    return instance
  end
  local creator = self:getCreator(type)
  if not creator then
    return instance
  end
  instance = creator.new(param)
  return instance
end

return BastionFactory

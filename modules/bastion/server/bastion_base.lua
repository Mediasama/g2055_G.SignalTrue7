local nextUid = 100000

local function getNextUid()
  local uid = nextUid
  nextUid = nextUid + 1
  return uid
end

local BastionBase = Lib.class("BastionBase")

function BastionBase:ctor(param)
  param = param or {}
  self._type = Define.Bastion.Type.None
  self._uid = param.uid or getNextUid()
  self._owner_id = nil
end

function BastionBase:destroy()
end

function BastionBase:update()
end

function BastionBase:getUid()
  return self._uid
end

function BastionBase:getOwnerId()
  return self._owner_id
end

function BastionBase:setOwnerId(id)
  self._owner_id = id
end

function BastionBase:onPlayerDie(id)
end

return BastionBase

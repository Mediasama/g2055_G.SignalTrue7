local nextUid = 100000

local function getNextUid()
  local uid = nextUid
  nextUid = nextUid + 1
  return uid
end

local GoodsShelfBase = Lib.class("GoodsShelfBase")

function GoodsShelfBase:ctor(param)
  param = param or {}
  self._type = Define.GoodsShelf.Type.None
  self._uid = param.id or getNextUid()
end

function GoodsShelfBase:destroy()
end

function GoodsShelfBase:update()
end

function GoodsShelfBase:getUid()
  return self._uid
end

return GoodsShelfBase

local GoodsShelfBase = require("server.goods_shelf_base")
local GoodsShelfBlackMarket = Lib.class("GoodsShelfBlackMarket", GoodsShelfBase)

function GoodsShelfBlackMarket:ctor(param)
  GoodsShelfBase.ctor(self, param)
  self._type = Define.GoodsShelf.Type.BlackMarket
  self._position = param.position or Vector3.new(0, 0, 0)
  self._rotation = param.rotation or Vector3.new(0, 0, 0)
  self._goodsList = param.goodsList or {}
  local map = World.CurWorld:getMap()
  local cfgName = "myplugin/trigger_goods_shelf_black_market"
  self._trigger = EntityServer.Create({
    cfgName = cfgName,
    map = map,
    pos = Vector3.new(self._position.x, self._position.y, self._position.z),
    ry = self._rotation.y,
    rp = self._rotation.x,
    rr = self._rotation.z
  })
  self._trigger:setRotation(self._rotation.y, self._rotation.x, self._rotation.z)
  self._trigger:gsp_setID(self:getUid())
end

return GoodsShelfBlackMarket

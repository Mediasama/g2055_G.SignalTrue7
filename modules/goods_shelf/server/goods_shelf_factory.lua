local GoodsShelfClothes = require("server.goods_shelf_clothes")
local GoodsShelfCar = require("server.goods_shelf_car")
local GoodsShelfWeapon = require("server.goods_shelf_weapon")
local GoodsShelfBlackMarket = require("server.goods_shelf_black_market")
local GoodsShelfBullet = require("server.goods_shelf_black_market")
local GoodsShelfFactory = Lib.class("GoodsShelfFactory")
local _instance

function GoodsShelfFactory.Instance()
  if _instance == nil then
    _instance = GoodsShelfFactory.new()
    _instance:init()
  end
  return _instance
end

function GoodsShelfFactory:ctor()
  self._creatorDict = {}
end

function GoodsShelfFactory:destroy()
end

function GoodsShelfFactory:init()
  self:registerCreator(Define.GoodsShelf.Type.Clothes, GoodsShelfClothes)
  self:registerCreator(Define.GoodsShelf.Type.Cars, GoodsShelfCar)
  self:registerCreator(Define.GoodsShelf.Type.Weapons, GoodsShelfWeapon)
  self:registerCreator(Define.GoodsShelf.Type.BlackMarket, GoodsShelfBlackMarket)
  self:registerCreator(Define.GoodsShelf.Type.Bullet, GoodsShelfBullet)
end

function GoodsShelfFactory:registerCreator(type, class)
  self._creatorDict[type] = class
end

function GoodsShelfFactory:getCreator(type)
  return self._creatorDict[type]
end

function GoodsShelfFactory:create(param)
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

return GoodsShelfFactory

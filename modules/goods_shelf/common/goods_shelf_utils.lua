local ClothesConfig = T(Config, "ClothesConfig")
local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
local WeaponConfig = T(Config, "WeaponConfig")
local GoodsShelfUtils = Lib.class("GoodsShelfUtils")
local _instance

function GoodsShelfUtils.Instance()
  if _instance == nil then
    _instance = GoodsShelfUtils.new()
    _instance:init()
  end
  return _instance
end

function GoodsShelfUtils:ctor()
end

function GoodsShelfUtils:init()
end

function GoodsShelfUtils:getGoodsConfig(type, id)
  if type == Define.GoodsShelf.Type.Clothes then
    return ClothesConfig:getCfgById(id)
  elseif type == Define.GoodsShelf.Type.Cars then
    return VehicleBaseConfig:getCfgById(id)
  elseif type == Define.GoodsShelf.Type.Weapons then
    return WeaponConfig:getCfgById(id)
  elseif type == Define.GoodsShelf.Type.Bullet then
    return WeaponConfig:getCfgById(id)
  elseif type == Define.GoodsShelf.Type.BlackMarket then
  end
  return nil
end

return GoodsShelfUtils

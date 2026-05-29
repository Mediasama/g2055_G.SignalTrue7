local handles = T(Player, "PackageHandlers")

function handles:C2S_RequestPurchaseGoods(packet)
  if self:isPlayerInDieState() then
    return
  end
  local type = packet.type or Define.GoodsShelf.Type.None
  local player = self
  if type == Define.GoodsShelf.Type.Clothes then
    return player:GoodsShelfBuyClothes(packet)
  elseif type == Define.GoodsShelf.Type.Cars then
    return player:GoodsShelfBuyCar(packet)
  elseif type == Define.GoodsShelf.Type.Weapons then
    return player:GoodsShelfBuyWeapon(packet)
  elseif type == Define.GoodsShelf.Type.BlackMarket then
    return player:GoodsShelfBuyBlackMarketItem(packet)
  elseif type == Define.GoodsShelf.Type.Bullet then
    return player:GoodsShelfBuyBullet(packet)
  elseif type == Define.GoodsShelf.Type.Item then
    return player:GoodsShelfBuyItem(packet)
  end
  local result = {}
  result.status = Define.GoodsShelf.PurchaseErrorCode.UnknownType
  result.msg = "unknown goods type:"
  return result
end

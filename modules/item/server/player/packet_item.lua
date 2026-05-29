local GoodsBaseConfig = T(Config, "GoodsBaseConfig")
local handles = T(Player, "PackageHandlers")

function handles:pickItemFromClient(packet)
  local drop = World.CurWorld:getObject(packet.objID)
  if drop then
    local itemData = drop:getItemData()
    if itemData.itemID == Define.GoldItemID then
      self:addCurrencyByName(Define.CURRENCY_TYPE.gold, itemData.count, itemData.isATM and Define.CurrencyReason.ATM or Define.CurrencyReason.Pick, itemData.dropState == Define.ItemDataDropState.SystemDrop and Define.CurrencyType.FromSystem or Define.CurrencyType.FromPlayer)
    elseif GoodsBaseConfig:isCostItem(itemData.itemID) then
      self:changeCostItemCount(itemData.itemID, itemData.count)
    else
      local source
      if itemData.dropState == Define.ItemDataDropState.SystemDrop then
        source = Define.ReportGetAccessType.SystemDrop
      elseif itemData.dropState == Define.ItemDataDropState.DieDrop then
        source = Define.ReportGetAccessType.DieDrop
      elseif itemData.dropState == Define.ItemDataDropState.Discard then
        source = Define.ReportGetAccessType.Discard
      end
      self:replaceHandBag(itemData, packet.index, true, source)
    end
    drop:destroy()
  end
end

local handles = T(Player, "PackageHandlers")

function handles:S2C_TriggerGoodsShelf(packet)
  local param = packet
  local operateType = param.operateType
  local objID = param.objID
  local shelfID = param.id
  local triggerParam = param.triggerParam or {}
  local player = Me
  if operateType == Define.GoodsShelf.Trigger.Type.Open then
    player:showGoodsShelfIcon(objID, shelfID, triggerParam)
  elseif operateType == Define.GoodsShelf.Trigger.Type.Close then
    player:hideGoodsShelfIcon(objID, shelfID, triggerParam)
  end
end

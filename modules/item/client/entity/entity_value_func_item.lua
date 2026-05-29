local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:handBag(data)
  self.handBagData = data
  Lib.emitEvent(Event.EVENT_ITEM_DATA_HANDBAG, data)
  if self.selectIndex and self.selectIndex > 1 and not data[self.selectIndex - 1] then
    local index = 1
    for i = 1, World.cfg.inventory.handBag do
      if data[i] then
        index = i + 1
        break
      end
    end
    Lib.emitEvent(Event.EVENT_ITEM_DATA_CLOTHESBAG, data, index)
  end
end

function Entity.ValueFunc:weaponBag(data)
  Lib.emitEvent(Event.EVENT_ITEM_DATA_WEAPONBAG, data)
end

function Entity.ValueFunc:clothesBag(data)
end

function Entity.ValueFunc:vehicleBag(data)
  Lib.emitEvent(Event.EVENT_ITEM_DATA_VEHICLEBAG, data)
end

function Entity.ValueFunc:costItemBag(data)
  Lib.emitEvent(Event.EVENT_ITEM_DATA_COSTITEM, data)
  print("Entity.ValueFunc:costItemBag(data)")
end

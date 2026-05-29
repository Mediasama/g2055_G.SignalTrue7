local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2055/\230\183\187\229\138\160\230\173\166\229\153\168"] = function(self)
  local ItemServer = T(Lib, "ItemServer")
  ItemServer:export_addHadBagItem(self, 102002)
end
GMItem["g2055/\229\138\160\233\135\145\229\184\129"] = function(self)
  self:addCurrencyByName(Define.CURRENCY_TYPE.gold, 1000, "gm")
end
GMItem["g2055/\229\135\143\233\135\145\229\184\129"] = function(self)
  local goldCount = self:getCurrencyById(Define.CURRENCY_ID.gold)
  print("goldCount", goldCount)
  self:payCurrencyById(Define.CURRENCY_ID.gold, goldCount, Define.CurrencyReason.Die)
  print("after count=", self:getCurrencyById(Define.CURRENCY_ID.gold))
end
GMItem["g2055/\230\137\147\229\141\176\229\138\160\233\135\145\229\184\129"] = function(self)
  local str = self:getCurrencyById(Define.CURRENCY_TYPE.gold)
  print("money=", str)
end
GMItem["g2055/\232\161\165\229\133\133\229\173\144\229\188\185"] = function(self)
  self:fillWeaponBullet(102002)
end
GMItem["g2055/\231\148\159\230\136\144\230\142\137\232\144\189"] = function(self)
  local diePos = self:getPosition()
  self.battleField:testDrops(diePos)
end
GMItem["g2055/\230\183\187\229\138\160\230\182\136\232\128\151\231\137\169"] = function(self)
  self:changeCostItemCount(80001, 100)
  print("\230\183\187\229\138\160\230\136\144\229\138\159")
end
GMItem["g2055/\230\137\147\229\141\176\230\182\136\232\128\151\231\137\169"] = function(self)
  local count = self:getCostItemCountByItemID(80001)
  print("\230\137\147\229\141\176\230\182\136\232\128\151\231\137\169:", count)
end
GMItem["g2055/\230\155\191\230\141\162\230\143\146\230\167\1891"] = function(self)
  local ItemServer = T(Lib, "ItemServer")
  local itemData = ItemServer:export_createInventoryItem(102002)
  self:replaceHandBag(itemData, 1, true)
end
GMItem["g2055/\229\136\160\233\153\164\230\143\146\230\167\1891"] = function(self)
  self:deleteHandBag(1)
end
GMItem["g2055/\232\162\171\229\135\187\233\128\1284"] = function(self)
  local diePos = self:getPosition()
  local pos = Lib.v3(diePos.x + 1, diePos.y + 1, diePos.z + 1)
  local time = 1
  self:setForceMove(pos, time)
  self:sendPacketToTracking({
    pid = "syncForceMoveToAll",
    objID = self.objID,
    pos = pos,
    time = time + 2
  }, true)
end
GMItem["g2055/\232\162\171\229\135\187\233\128\1285"] = function(self)
  local diePos = self:getPosition()
  local pos = Lib.v3(diePos.x + 1, diePos.y + 1, diePos.z + 1)
  local time = 1
  self:setForceMove(pos, nil)
  self:sendPacketToTracking({
    pid = "syncForceMoveToAll",
    objID = self.objID,
    pos = pos,
    time = time
  }, true)
end
GMItem["g2055/\230\155\180\230\141\162\230\139\179\229\164\180"] = function(self)
  self:resetDefaultWeapon()
end
GMItem["g2055/\230\173\166\229\153\168\233\151\170\231\131\129"] = function(self)
  self:sendPacket({
    pid = "onMeleeTwinkle",
    index = 0
  })
end
GMItem["g2055/\230\173\166\229\153\168\229\136\160\233\153\164"] = function(self)
  self:destroyMeleeWeapon(2)
end

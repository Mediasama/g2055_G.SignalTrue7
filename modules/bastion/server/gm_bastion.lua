local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\162\158\229\138\160\231\142\176\233\135\145"] = GM:inputStr(function(self, value)
  local amount = tonumber(value) or 0
  if 0 < amount then
    self:addCurrencyById(Define.Bastion.Currency.Type.Gold, amount, "GM")
  end
end, function(self)
  return "100"
end)
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\162\158\229\138\160\228\189\153\233\162\157"] = GM:inputStr(function(self, value)
  local amount = tonumber(value) or 0
  if 0 < amount then
    self:addBastionCurrency(Define.Bastion.Currency.Type.Gold, amount)
  end
end, function(self)
  return "100"
end)
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\162\158\229\138\160\230\156\141\232\163\133"] = GM:inputStr(function(self, value)
  local id = tonumber(value) or 0
  if 40000 < id then
    local item = {}
    item.id = id
    self:addBastionClothesItem(item)
  end
end, function(self)
  return "40001"
end)
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\162\158\229\138\160\228\184\135\232\131\189\233\146\165\229\140\153"] = GM:inputStr(function(self, value)
  local amount = tonumber(value) or 0
  self:changeCostItemCount(Define.Bastion.DoorHackItemID, amount)
end, function(self)
  return "1"
end)
local ItemServer = T(Lib, "ItemServer")
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\162\158\229\138\160\230\137\139\229\140\133\230\173\166\229\153\168"] = GM:inputStr(function(self, value)
  local id = tonumber(value) or 0
  ItemServer:export_addHadBagItem(self, id)
end, function(self)
  return "102001"
end)
local WeaponConfig = T(Config, "WeaponConfig")
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\162\158\229\138\160\229\186\147\229\173\152\230\173\166\229\153\168"] = GM:inputStr(function(self, value)
  local id = tonumber(value) or 0
  local config = WeaponConfig:getCfgById(id)
  if config then
    local bulletCount = config.bulletCount
    if 0 < bulletCount then
      bulletCount = math.random(1, bulletCount)
    end
    local item = {id = id, bulletCount = bulletCount}
    self:addBastionArmoryItem(item)
  end
end, function(self)
  return "102003"
end)
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\229\136\135\230\141\162\228\189\143\229\174\133"] = GM:inputStr(function(self, value)
  local bastionId = tonumber(value) or 1
  if 1 <= bastionId then
    local BastionManager = require("server.bastion_manager")
    local curBastion = self:getBastion()
    local curBastionId = curBastion:getUid()
    print("------------------------------------------ curBastionId ", curBastionId)
    if curBastionId ~= bastionId then
      self:releaseBastion()
      local bastion = BastionManager.Instance():distributeBastionGM(self.platformUserId, bastionId)
      if bastion then
        self:bhp_setBastionPosition(bastion:getWorldPosition())
        local pos = self.battleField:getBirthPos(self)
        self:setMapPos("map001", pos)
      end
    end
  end
end, function(self)
  return "1"
end)

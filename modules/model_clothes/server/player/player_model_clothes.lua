local ClothesConfig = T(Config, "ClothesConfig")
local PlayerModelClothesServer = EntityServerPlayer

function PlayerModelClothesServer:wearClothesItem(part, item)
  if not item then
    return
  end
  local clothesId = item.id
  if not clothesId then
    return
  end
  local configItem = ClothesConfig:getCfgById(clothesId)
  if not configItem then
    return
  end
  if configItem.part == Define.ModelClothes.Type.Tattoo then
    if configItem.take_off_part ~= Define.ModelClothes.Type.None then
      self:setModelClothesItem(configItem.take_off_part, nil)
    end
  else
    local tattooItem = self:getModelClothesItem(Define.ModelClothes.Type.Tattoo)
    if tattooItem then
      local tattooConfig = ClothesConfig:getCfgById(tattooItem.id)
      if tattooConfig and tattooConfig.take_off_part == configItem.part then
        self:setModelClothesItem(Define.ModelClothes.Type.Tattoo, nil)
      end
    end
  end
  self:setModelClothesItem(part, item)
  self:updateModelClothes()
end

function PlayerModelClothesServer:takeOffClothesItem(part, item)
  if not item then
    return
  end
  local clothesId = item.id
  if not clothesId then
    return
  end
  local configItem = ClothesConfig:getCfgById(clothesId)
  if not configItem then
    return
  end
  self:setModelClothesItem(part, nil)
  self:updateModelClothes()
end

function PlayerModelClothesServer:updateModelClothes()
  local platformSkinData = self:getPlatformSkinData()
  local clothesData = Lib.copy(platformSkinData)
  local wearDict = self:getModelClothesWearDict()
  for part, item in pairs(wearDict) do
    local configItem = ClothesConfig:getCfgById(item.id)
    local skin_data = configItem.skin_data or {}
    for key, v in pairs(skin_data) do
      clothesData[key] = v
    end
  end
  self:changeSkin(clothesData)
end

function PlayerModelClothesServer:getPlatformSkinData()
  return self.platformSkinData or {}
end

function PlayerModelClothesServer:setPlatformSkinData()
  local keys = {
    "custom_hair",
    "custom_face",
    "clothes_tops",
    "clothes_pants",
    "custom_shoes"
  }
  local skinData = self:data("skin")
  self.platformSkinData = {}
  for index, key in pairs(keys) do
    self.platformSkinData[key] = skinData[key] or ""
  end
end

function PlayerModelClothesServer:initModelClothes()
  self:setPlatformSkinData()
  self:updateModelClothes()
end

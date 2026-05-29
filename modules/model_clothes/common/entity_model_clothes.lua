local ValueDef = T(Entity, "ValueDef")
ValueDef.model_clothes = {
  false,
  false,
  true,
  false,
  {},
  true
}
local EntityModelClothes = Entity

function EntityModelClothes:getModelClothes()
  return self:getValue("model_clothes") or {}
end

function EntityModelClothes:setModelClothes(value)
  self:setValue("model_clothes", value)
end

function EntityModelClothes:getModelClothesWearDict()
  local clothes = self:getModelClothes()
  return clothes.wearDict or {}
end

function EntityModelClothes:setModelClothesWearDict(dict)
  local clothes = self:getModelClothes()
  clothes.wearDict = dict
  self:setModelClothes(clothes)
end

function EntityModelClothes:getModelClothesItem(part)
  local wearDict = self:getModelClothesWearDict()
  return wearDict[part]
end

function EntityModelClothes:setModelClothesItem(type, item)
  local oldId
  local oldItem = self:getModelClothesItem(type)
  if oldItem then
    oldId = oldItem.id
  end
  local wearDict = self:getModelClothesWearDict()
  wearDict[type] = item
  self:setModelClothesWearDict(wearDict)
  local newId
  if item then
    newId = item.id
  end
  local reportData = {}
  reportData.clothing_type = type
  reportData.clothing_id_before = oldId
  reportData.clothing_id_after = newId
  self:evt_reportEvent(Define.EventTracking.Type.ChangeClothes, reportData)
end

function EntityModelClothes:isWearingClothesItem(id)
  local wearDict = self:getModelClothesWearDict()
  for type, item in pairs(wearDict) do
    if item.id == id then
      return true
    end
  end
  return false
end

function EntityModelClothes:getWearingClothesReportData()
  local data = ""
  local wearDict = self:getModelClothesWearDict()
  for type, item in pairs(wearDict) do
    data = data .. item.id .. ","
  end
  return data
end

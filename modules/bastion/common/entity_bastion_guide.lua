local ValueDef = T(Entity, "ValueDef")
ValueDef.bastion_guide = {
  false,
  false,
  true,
  true,
  {},
  true
}
local EntityBastion = Entity

function EntityBastion:getBastionGuide()
  return self:getValue("bastion_guide") or {}
end

function EntityBastion:setBastionGuide(value)
  self:setValue("bastion_guide", value)
end

function EntityBastion:getBastionGuideDict()
  local guide = self:getBastionGuide()
  return guide.guideDict or {}
end

function EntityBastion:setBastionGuideDict(dict)
  local guide = self:getBastionGuide()
  guide.guideDict = dict
  self:setBastionGuide(guide)
end

function EntityBastion:getBastionGuideItem(key)
  local dict = self:getBastionGuideDict()
  return dict[key]
end

function EntityBastion:setBastionGuideItem(key, item)
  local dict = self:getBastionGuideDict()
  dict[key] = item
  self:setBastionGuideDict(dict)
end

function EntityBastion:getBastionGuideTimes(key)
  local item = self:getBastionGuideItem(key)
  if not item then
    return 0
  end
  return item.times or 0
end

function EntityBastion:recordBastionGuideTimes(key)
  local item = self:getBastionGuideItem(key)
  item = item or {times = 0}
  item.times = item.times + 1
  self:setBastionGuideItem(key, item)
end

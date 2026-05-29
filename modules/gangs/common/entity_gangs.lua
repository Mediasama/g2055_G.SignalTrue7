local ValueDef = T(Entity, "ValueDef")
ValueDef.gangIconInfo = {
  false,
  false,
  true,
  true,
  nil,
  false
}
ValueDef.killPlayerDict = {
  false,
  false,
  true,
  true,
  {},
  false
}
local Entity = _ENV.Entity

function Entity:addKillPlayerDict(id)
  if not id then
    return
  end
  local map = self:getKillPlayerDict()
  map[id] = 1
  self:setKillPlayerDict(map)
end

function Entity:setKillPlayerDict(value)
  self:setValue("killPlayerDict", value)
end

function Entity:getKillPlayerDict()
  return self:getValue("killPlayerDict")
end

function Entity:checkPlayerKillMe(id)
  local map = self:getKillPlayerDict()
  return map[id] == 1
end

function Entity:getCircleType()
  if Me:isSameGang2(self) then
    return Define.GangPlayerCircleType.Green
  else
    return self:checkPlayerKillMe(Me.platformUserId) and Define.GangPlayerCircleType.Red or Define.GangPlayerCircleType.Yellow
  end
end

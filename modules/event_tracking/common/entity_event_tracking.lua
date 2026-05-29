local ValueDef = T(Entity, "ValueDef")
ValueDef.battle_id = {
  false,
  true,
  true,
  false,
  0,
  true
}
ValueDef.game_id = {
  false,
  true,
  true,
  false,
  nil,
  false
}
ValueDef.evt_tmp_data = {
  false,
  true,
  true,
  false,
  {},
  false
}
ValueDef.playerActive = {
  false,
  true,
  true,
  false,
  {},
  true
}
local EntityEventTracking = Entity

function EntityEventTracking:evt_getTempData()
  return self:getValue("evt_tmp_data")
end

function EntityEventTracking:evt_setTempData(value)
  self:setValue("evt_tmp_data", value)
end

function EntityEventTracking:evt_getLastEnterAreaTime()
  local data = self:evt_getTempData()
  return data.lastEnterAreaTime or 0
end

function EntityEventTracking:evt_setLastEnterAreaTime(time)
  local data = self:evt_getTempData()
  data.lastEnterAreaTime = time
  self:evt_setTempData(data)
end

function EntityEventTracking:evt_getStayAreaTime()
  local enterTime = self:evt_getLastEnterAreaTime()
  return os.time() - enterTime
end

function EntityEventTracking:evt_startStayArea()
  self:evt_setLastEnterAreaTime(os.time())
end

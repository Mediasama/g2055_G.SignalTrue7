local StateDead = Lib.class("StateDead", require("common.state.state_base"))

local function createDropPos(list)
  local dieDropRate = World.cfg.dieDropRate
  local num = math.random(0, 99)
  local count
  for i, v in ipairs(dieDropRate) do
    if v > num then
      count = i - 1
      break
    end
  end
  local hasList = {}
  for i = 1, 3 do
    if list[i] then
      table.insert(hasList, i)
    end
  end
  local posList = {}
  if #hasList == 0 then
  elseif count >= #hasList then
    posList = hasList
  elseif count == 1 then
    local p = math.random(1, #hasList)
    posList = {
      hasList[p]
    }
  elseif count == 2 then
    local p = math.random(1, 3)
    for i = 1, 3 do
      if i ~= p then
        table.insert(posList, i)
      end
    end
  end
  return posList
end

local function calculateGold(goldCount)
  local count = 0
  if goldCount > World.cfg.dieKeepGold then
    count = math.min(math.floor(goldCount * World.cfg.dieDropGoldPercent / 100), goldCount - World.cfg.dieKeepGold)
  end
  return count
end

function StateDead:enter(param)
  print("StateDead:enter(param)")
  if self.entity.weapon.id ~= World.cfg.defaultWeaponID then
    self.entity.weapon:release()
  end
  local pos = self.entity:getPosition()
  local list = Lib.copy(self.entity:getInventory(Define.InventoryType.HandBag))
  local goldCount = self.entity:getCurrencyById(Define.CURRENCY_ID.gold)
  goldCount = calculateGold(goldCount)
  local posList = createDropPos(list)
  local dropList = {}
  for i, v in ipairs(posList) do
    table.insert(dropList, list[v])
  end
  self.entity.battleField:onAddDrops(dropList, pos, goldCount)
  self.entity:clearHandBagAndMoney(dropList, goldCount, posList)
  self.entity:setActionIdle("g2055_dead_1")
  self.beginTickCount = World.CurWorld:getTickCount()
  local packet = {
    pid = "EntityPlayAction",
    objID = self.entity.objID,
    action = "idle",
    time = -1,
    refreshBaseAction = true
  }
  self.entity:sendPacketToTracking(packet, true)
end

function StateDead:update()
  local curTick = World.CurWorld:getTickCount()
  local reliveTime = World.cfg.deathCameraCfg.reliveTime
  if reliveTime <= (curTick - self.beginTickCount) * Lib.tickToTime(1) / 1000 then
    self.entity:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
  end
end

function StateDead:leave(param)
end

return StateDead

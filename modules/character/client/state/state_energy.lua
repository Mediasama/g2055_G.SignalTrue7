local StateEnergy = Lib.class("StateEnergy", require("common.state.state_base"))

function StateEnergy:enter(param)
  local actionName, time = Me.weapon:getCastActionAndTime()
  self.totalTick = time
  self.entity:sendPacket({
    pid = "playerAction",
    actionName = actionName,
    time = -1
  })
  self.entity:updateUpperAction1(actionName, -1, true, 0, true)
  self.beginTickCount = World.CurWorld:getTickCount()
  Blockman.instance:control().enable = false
end

function StateEnergy:update()
  local curTick = World.CurWorld:getTickCount()
  if curTick - self.beginTickCount >= self.totalTick then
    Me:RechargeFull()
  end
end

function StateEnergy:leave(param)
  Blockman.instance:control().enable = true
  Me:sendPacket({
    pid = "resetRecharge"
  })
  local actionName = "idle"
  self.entity:sendPacket({
    pid = "playerAction",
    actionName = actionName,
    time = -1
  })
  self.entity:updateUpperAction1(actionName, -1, true, 0, true)
end

return StateEnergy

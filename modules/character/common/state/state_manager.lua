local StateManager = Lib.class("StateManager")
local StateMappingClient = {
  [Define.CHARACTER_STATE_TYPE.NORMAL] = require("client.state.state_normal"),
  [Define.CHARACTER_STATE_TYPE.ENERGY] = require("client.state.state_energy"),
  [Define.CHARACTER_STATE_TYPE.SKILL] = require("client.state.state_skill"),
  [Define.CHARACTER_STATE_TYPE.DRIVE] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.GROUND] = require("client.state.state_ground"),
  [Define.CHARACTER_STATE_TYPE.DIE] = require("client.state.state_dead"),
  [Define.CHARACTER_STATE_TYPE.CARRY] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.BeCARRY] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.INTERACTIVE] = require("common.state.state_base")
}
local StateMappingServer = {
  [Define.CHARACTER_STATE_TYPE.NORMAL] = require("server.state.state_normal"),
  [Define.CHARACTER_STATE_TYPE.ENERGY] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.SKILL] = require("server.state.state_skill"),
  [Define.CHARACTER_STATE_TYPE.DRIVE] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.GROUND] = require("server.state.state_ground"),
  [Define.CHARACTER_STATE_TYPE.DIE] = require("server.state.state_dead"),
  [Define.CHARACTER_STATE_TYPE.CARRY] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.BeCARRY] = require("common.state.state_base"),
  [Define.CHARACTER_STATE_TYPE.INTERACTIVE] = require("common.state.state_base")
}

function StateManager:ctor(entity)
  print("StateManager:ctor", entity)
  self.entity = entity
  self.logicTimer = World.LightTimer("StateManager", 1, function()
    self:update()
    return true
  end)
end

function StateManager:init()
end

function StateManager:changeState(state, param)
  if not self.entity:isValid() then
    return
  end
  param = param or {}
  if self.curState and not self.curState:isCanInterrupt() then
    print("state can not be interrupt", self.curState:getState())
    return
  end
  local class = StateMappingServer[state]
  if World.isClient then
    class = StateMappingClient[state]
  end
  local newState
  if class then
    newState = class.new(self.entity, state, self)
  else
    print("state not class", state)
    return
  end
  if newState and not newState:isCanEnter() then
    print("state can not enter", state)
    return
  end
  if self.curState then
    self.curState:leave(param)
  end
  newState:enter(param)
  self.curState = newState
  if World.isClient then
    if not param.notSendServer then
      print(" Me:sendPacket({ pid = , state = state, param = param })", Me, state, param)
      Me:sendPacket({
        pid = "changeState2s",
        state = state,
        param = param
      })
    end
  else
    self.entity:setCharacterState(state)
  end
end

function StateManager:getCurState()
  local state = Define.CHARACTER_STATE_TYPE.NORMAL
  if self.curState then
    state = self.curState:getState()
  end
  return state
end

function StateManager:update()
  if self.entity and not self.entity:isValid() then
    if self.logicTimer then
      self.logicTimer()
      self.logicTimer = nil
    end
    return
  end
  if self.curState then
    self.curState:update()
  end
end

return StateManager

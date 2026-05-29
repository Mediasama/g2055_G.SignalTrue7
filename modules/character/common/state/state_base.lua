local StateBase = Lib.class("StateBase")

function StateBase:ctor(entity, state, stateManager)
  self.entity = entity
  self.state = state
  self.stateManager = stateManager
end

function StateBase:getState()
  return self.state
end

function StateBase:enter(param)
end

function StateBase:update()
end

function StateBase:leave(param)
end

function StateBase:isCanEnter()
  return true
end

function StateBase:isCanInterrupt()
  return true
end

return StateBase

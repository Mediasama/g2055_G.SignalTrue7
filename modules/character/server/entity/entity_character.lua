local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function Entity:checkIsState(state)
  if not self.getCurState then
    return false
  end
  local curState = self:getCurState()
  return curState == state
end

function Entity:changeState(state, param)
  if self.stateManager then
    self.stateManager:changeState(state, param)
  end
end

function Entity:getCurState()
  if self.stateManager then
    return self.stateManager:getCurState()
  else
    return self:getCharacterState()
  end
end

local stateNormal = Lib.class("stateNormal", require("common.state.state_base"))

function stateNormal:enter(param)
  local state = self.entity:getCurState()
  if state == Define.CHARACTER_STATE_TYPE.DIE then
    print("client stateNormal:enter(param)")
  end
end

function stateNormal:leave(param)
end

return stateNormal

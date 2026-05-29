local StateGround = Lib.class("StateGround", require("common.state.state_base"))

function StateGround:enter(param)
  Blockman.instance:control().enable = false
end

function StateGround:update()
end

function StateGround:leave(param)
  Blockman.instance:control().enable = true
end

return StateGround

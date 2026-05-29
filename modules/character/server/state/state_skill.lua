local WeaponConfig = T(Config, "WeaponConfig")
local StateSkill = Lib.class("StateSkill", require("common.state.state_base"))

function StateSkill:enter(param)
  local skillName = param.skillName
  self.entity.skillJsonConf = WeaponConfig:getSkillJsonByName(skillName)
end

function StateSkill:update()
end

function StateSkill:leave(param)
  self.entity.skillJsonConf = nil
end

return StateSkill

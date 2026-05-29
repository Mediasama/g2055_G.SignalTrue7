local GuideConfig = require("common.config.guide_config")
local handles = T(Player, "PackageHandlers")

function handles:saveGuideID(packet)
  self:saveGuideID(packet.id)
end

function handles:sendGuideGold(packet)
  local config = GuideConfig:getCfgById(packet.id)
  self:addCurrencyByName(Define.CURRENCY_TYPE.gold, config.goldCount, Define.CurrencyReason.Pick, Define.CurrencyType.FromPlayer)
end

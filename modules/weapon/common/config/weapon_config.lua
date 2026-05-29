local WeaponConfig = T(Config, "WeaponConfig")
local setting = require("common.setting")
local weaponDict = {}
local createAimInfoTable

function createAimInfoTable(aimInfo)
  local aimInfoTab = Lib.splitString(aimInfo, "#")
  local data = {
    reticleSize = aimInfoTab[1] and tonumber(aimInfoTab[1]),
    reticleEnlargeSpeed = aimInfoTab[2] and tonumber(aimInfoTab[2]),
    reticleShrinkSpeedTimer = aimInfoTab[3] and tonumber(aimInfoTab[3]),
    minimumAccuracy = aimInfoTab[4] and tonumber(aimInfoTab[4])
  }
  return data
end

function WeaponConfig:initWeaponConfig()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/weapon.csv", 2)
  for _, vConfig in pairs(config) do
    local id = tonumber(vConfig.n_id) or 0
    local data = {
      id = id,
      name = vConfig.s_name or "",
      desc = vConfig.s_desc or "",
      itemIcon = vConfig.s_item_icon or "",
      longItemIcon = vConfig.s_long_item_icon or "",
      bulletCount = tonumber(vConfig.n_bullet_count) or 0,
      price = tonumber(vConfig.n_price) or 0,
      currencyType = tonumber(vConfig.n_currency_type) or 0,
      bulletCurrencyType = tonumber(vConfig.n_bullet_currency_type) or 0,
      bulletPrice = tonumber(vConfig.n_bullet_price) or 0,
      showModName = vConfig.s_showModName,
      fire = vConfig.s_fire or "",
      aimIcon = vConfig.s_aimIcon and Lib.splitString(vConfig.s_aimIcon, "#"),
      aimInfo = vConfig.s_aimInfo and vConfig.s_aimInfo ~= "" and createAimInfoTable(vConfig.s_aimInfo),
      actions = self:pairsListStr(vConfig.s_actions),
      part = self:pairsPart(vConfig.s_part),
      item_model = vConfig.s_item_model or "",
      weaponType = tonumber(vConfig.weapon_damage_level)
    }
    weaponDict[data.id] = data
  end
end

function WeaponConfig:pairsListStr(s)
  local t = {}
  local l = Lib.split(s, "#")
  if #l == 0 then
    return
  end
  for _, v in pairs(l) do
    table.insert(t, v)
  end
  return t
end

function WeaponConfig:pairsPart(s)
  if s == "" then
    return
  end
  local t = {}
  local l = Lib.split(s, ":")
  if #l == 0 then
    return
  end
  t[l[1]] = l[2]
  return t
end

function WeaponConfig:getWeaponDict()
  return weaponDict
end

function WeaponConfig:getCfgById(id)
  local cfg = weaponDict[id]
  if not cfg then
    Lib.logError("can not find WeaponConfig, id:", id)
    return
  end
  return cfg
end

local jsonMapping = {}

function WeaponConfig:getWeaponJsonById(id)
  local cfg = WeaponConfig:getCfgById(id)
  if cfg then
    if not jsonMapping[id] then
      jsonMapping[id] = setting:fetch("launcher", cfg.fire)
    end
    return jsonMapping[id]
  end
end

local skillJsonMapping = {}

function WeaponConfig:getSkillJsonByName(skillName)
  if not skillJsonMapping[skillName] then
    skillJsonMapping[skillName] = setting:fetch("skill", skillName)
  end
  return skillJsonMapping[skillName]
end

WeaponConfig:initWeaponConfig()
return WeaponConfig

local DoorsConfig = T(Config, "DoorsConfig")
local settings = {}

function DoorsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/doors.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.isHomeDoor = (tonumber(vConfig.b_is_home_door) or 0) == 1
    item.name = vConfig.s_name
    item.entityCfg = "myplugin/" .. (vConfig.s_entity_cfg or "")
    item.icon = vConfig.s_icon
    item.createSound = vConfig.s_create_sound_key
    item.hurtSound = vConfig.s_hurt_sound_key
    item.damagedSound = vConfig.s_damaged_sound_key
    item.startHackSound = vConfig.s_start_hack_sound_key
    item.succeedHackSound = vConfig.s_succeed_hack_sound_key
    item.failedHackSound = vConfig.s_failed_hack_sound_key
    item.price = tonumber(vConfig.n_price) or 1
    item.maxHp = tonumber(vConfig.n_max_hp) or 1
    item.defenseLevel = tonumber(vConfig.n_def_lv) or 1
    item.defense = tonumber(vConfig.n_def) or 1
    item.hackProbability = tonumber(vConfig.n_hack_probability) or 1
    item.damagedRecoverTime = tonumber(vConfig.n_damaged_recover_time) or 1
    item.hackedRecoverTime = tonumber(vConfig.n_hacked_recover_time) or 1
    item.hackTime = tonumber(vConfig.n_hack_time) or 1
    item.totalGearCount = tonumber(vConfig.n_total_gear_count) or 1
    item.greenGearCount = tonumber(vConfig.n_green_gear_count) or 1
    item.cursorSpeed = tonumber(vConfig.n_cursor_speed) or 1
    item.penaltyTime = tonumber(vConfig.n_penalty_time) or 1
    settings[item.id] = item
  end
end

function DoorsConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgDoorsConfig, id:", id)
    return
  end
  return settings[id]
end

function DoorsConfig:getAllCfgs()
  return settings
end

DoorsConfig:init()
return DoorsConfig

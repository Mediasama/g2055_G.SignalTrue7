local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
local settings = {}

function VehicleBaseConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/vehicle_base.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      vehicle_icon = vConfig.s_vehicle_icon or "",
      vehicle_name = vConfig.s_vehicle_name or "",
      vehicle_type = tonumber(vConfig.n_vehicle_type) or 0,
      throwCfgName = vConfig.s_throwCfgName or "",
      vehicle_hp = tonumber(vConfig.n_vehicle_hp) or 0,
      vehicle_attack = tonumber(vConfig.n_vehicle_attack) or 0,
      vehicle_damage_lv = tonumber(vConfig.n_vehicle_damage_lv) or 0,
      vehicle_defence_lv = tonumber(vConfig.n_vehicle_defence_lv) or 0,
      vehicle_defense = tonumber(vConfig.n_vehicle_defense) or 0,
      vehicle_is_lock = tonumber(vConfig.n_vehicle_is_lock) or 0,
      vehicle_unlock_item = tonumber(vConfig.n_vehicle_unlock_item) or 0,
      vehicle_unlock_time = tonumber(vConfig.n_vehicle_unlock_time) or 0,
      vehicle_unlock_pro = tonumber(vConfig.n_vehicle_unlock_pro) or 0,
      vehicle_exhaust_hold = vConfig.s_vehicle_exhaust_hold or "",
      vehicle_price = tonumber(vConfig.n_price) or 0
    }
    settings[data.id] = data
  end
end

function VehicleBaseConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgVehicleBaseConfig, id:", id)
    return
  end
  return settings[id]
end

function VehicleBaseConfig:getAllCfgs()
  return settings
end

VehicleBaseConfig:init()
return VehicleBaseConfig

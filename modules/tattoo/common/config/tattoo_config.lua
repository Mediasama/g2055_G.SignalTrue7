local TattooConfig = T(Config, "TattooConfig")
local settings = {}

function TattooConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/tattoo.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      pos = vConfig.s_pos or "",
      cfg_name = vConfig.s_cfg_name or "",
      clothes_id = vConfig.s_clothes_id or "",
      rotation = vConfig.s_rotation or "",
      tattoo_time = tonumber(vConfig.n_tattoo_time) or 0
    }
    local l = Lib.split(data.clothes_id, "&")
    data.clothes_id = {}
    for i = 1, #l do
      data.clothes_id[i] = tonumber(l[i])
    end
    local tmp = Lib.splitString(data.pos, ",")
    data.pos = {
      x = tonumber(tmp[1]),
      y = tonumber(tmp[2]),
      z = tonumber(tmp[3])
    }
    tmp = Lib.splitString(data.rotation, ",")
    data.rotation = {
      x = tonumber(tmp[1]),
      y = tonumber(tmp[2]),
      z = tonumber(tmp[3])
    }
    settings[data.id] = data
  end
end

function TattooConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgTattooConfig, id:", id)
    return
  end
  return settings[id]
end

function TattooConfig:getAllCfgs()
  return settings
end

TattooConfig:init()
return TattooConfig

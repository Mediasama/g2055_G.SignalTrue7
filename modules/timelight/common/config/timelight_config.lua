local TimeLightConfig = T(Config, "TimeLightConfig")

function TimeLightConfig:init()
  self.settings = {}
  local config = Lib.read_gamepath_csv("config/time_light.csv", {
    time = "#n",
    direct = "#n",
    ambient = "#n",
    diffuse = "#n",
    specular = "#n",
    exposure = "n",
    gamma = "n",
    SSAOIntensity = "n"
  }, 2)
  for i, row in ipairs(config) do
    self.settings[i] = {
      second = Lib.time2Seconds(row.time[1], row.time[2]),
      direct = Lib.v3(row.direct[1], row.direct[2], row.direct[3]),
      ambient = {
        row.ambient[1] / 255,
        row.ambient[2] / 255,
        row.ambient[3] / 255,
        1
      },
      diffuse = {
        row.diffuse[1] / 255,
        row.diffuse[2] / 255,
        row.diffuse[3] / 255,
        1
      },
      specular = {
        row.specular[1] / 255,
        row.specular[2] / 255,
        row.specular[3] / 255,
        1
      },
      exposure = row.exposure or 0,
      gamma = row.gamma or 0,
      SSAOIntensity = row.SSAOIntensity or 0
    }
  end
end

function TimeLightConfig:getByTime(sec)
  local fromIndex, toIndex
  for i, v in ipairs(self.settings) do
    if sec < v.second then
      toIndex = i
      break
    end
  end
  if not toIndex then
    fromIndex = #self.settings
    toIndex = 1
  else
    fromIndex = toIndex - 1
    if fromIndex < 1 then
      fromIndex = #self.settings
    end
  end
  return self.settings[fromIndex], self.settings[toIndex]
end

TimeLightConfig:init()

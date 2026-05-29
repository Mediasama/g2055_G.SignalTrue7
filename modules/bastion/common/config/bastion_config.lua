local BastionConfig = T(Config, "BastionConfig")
local settings = {}

function BastionConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/bastion.csv", 2)
  for _, vConfig in pairs(config) do
    local item = {}
    item.id = tonumber(vConfig.n_id) or 0
    item.description = vConfig.s_description or ""
    item.reborn = self:parseFacilityInfo(vConfig.s_reborn or "")
    item.door = self:parseFacilityInfo(vConfig.s_door or "")
    item.closet = self:parseFacilityInfo(vConfig.s_closet or "")
    item.closetEffect = self:parseFacilityInfo(vConfig.s_closet_effect or "")
    item.armory = self:parseFacilityInfo(vConfig.s_armory or "")
    item.armoryEffect = self:parseFacilityInfo(vConfig.s_armory_effect or "")
    item.vault = self:parseFacilityInfo(vConfig.s_vault or "")
    item.vaultEffect = self:parseFacilityInfo(vConfig.s_vault_effect or "")
    item.garage = self:parseFacilityInfo(vConfig.s_garage or "")
    item.park = self:parseFacilityInfo(vConfig.s_park or "")
    item.toolkit = self:parseFacilityInfo(vConfig.s_took_kit or "")
    item.toolkitEffect = self:parseFacilityInfo(vConfig.s_took_kit_effect or "")
    item.doorplate = self:parseFacilityInfo(vConfig.s_doorplate or "")
    item.carposition = self:parseFacilityInfo(vConfig.s_carposition or "")
    settings[item.id] = item
  end
end

function BastionConfig:parseTransform(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local x = tonumber(samplesStr[1]) or 0
  local y = tonumber(samplesStr[2]) or 0
  local z = tonumber(samplesStr[3]) or 0
  return Vector3.new(x, y, z)
end

function BastionConfig:parseFacilityInfo(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "#")
  local result = {}
  result.position = self:parseTransform(samplesStr[1] or "")
  result.rotation = self:parseTransform(samplesStr[2] or "")
  return result
end

function BastionConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgBastionConfig, id:", id)
    return
  end
  return settings[id]
end

function BastionConfig:getAllCfgs()
  return settings
end

BastionConfig:init()
return BastionConfig

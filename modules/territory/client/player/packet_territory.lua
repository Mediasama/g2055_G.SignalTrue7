local SoundConfig = T(Config, "SoundConfig")
local TerritoryConfig = T(Config, "TerritoryConfig")
local handles = T(Player, "PackageHandlers")

function handles:onAreaTriggerOperation(packet)
  local operateType = packet.operateType
  local areaObjectData = packet.areaObjectData
  if operateType == Define.TerritoryTriggerType.Enter then
  else
    Lib.emitEvent(Event.CLOSE_AREA_TIPS)
  end
end

function handles:onTerritoryTriggerOperation(packet)
  local operateType = packet.operateType
  local objID = packet.objID
  local territoryData = packet.territoryData
  if operateType == Define.TerritoryTriggerType.Enter then
    self:showTerritoryView(objID, territoryData)
  else
    self:hideTerritoryView(objID)
  end
end

function handles:onOccupySuccess(packet)
  local cfg = TerritoryConfig:getCfgById(packet.id)
  if cfg == nil then
    return
  end
  local str = Lang:getMessage("territory.tips.occupy.success")
  local text = string.format(str, Lang:getMessage(cfg.name))
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", text)
  Lib.emitEvent(Event.UPDATE_TERRITORY_OCCUPY_STATUS, packet.territoryData, packet.id)
  self:playSoundByKey("g2055_trigger_territoryOccupiedSuccessfully")
end

function handles:onUpdateTerritoryOccupyInfo(packet)
  Lib.emitEvent(Event.UPDATE_TERRITORY_OCCUPY_STATUS, packet.occupyInfo, packet.id)
end

function handles:onOccupyGetAward(packet)
  local id = packet.id
  local cfg = TerritoryConfig:getCfgById(id)
  if cfg == nil then
    return
  end
  local str = Lang:getMessage("territory.tips.occupy.get.award")
  local text = string.format(str, Lang:getMessage(cfg.name), packet.amount)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", text)
end

function handles:onInterruptTerritoryOccupy(packet)
  self:hideTerritoryView(packet.objID)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("territory.tips.occupy.interrupt"))
end

function handles:onNotifyTerritorySwitchOwner(packet)
  local str
  if packet.type == Define.TerritoryOwnerType.Gang then
    if packet.enterGang then
      str = Lang:getMessage("territory.tips.occupied.by.enter.gang")
    else
      str = Lang:getMessage("territory.tips.occupied.by.gang")
    end
  else
    str = Lang:getMessage("territory.tips.occupied.by.player")
  end
  local text = string.format(str, Lang:getMessage(packet.territoryName), packet.name)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", text)
end

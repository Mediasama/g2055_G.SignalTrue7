local TerritoryEffectNode = require("client.territory_effect")
local Entity = _ENV.Entity

function Entity:updateEntityEnter()
  self:initTerritoryEffect()
  self:updateTerritoryOwnerEntityEffect()
end

function Entity:updateTerritoryHeadName()
  if self:cfg().syncHeadName then
    local name = self:getValue("territoryOwner").name
    if name then
      self:setShowName(name)
    else
      self:setShowName(Lang:toText("territory.ui.tips.unOccupied"))
    end
  end
end

function Entity:isTerritoryMyCamp()
  local data = self:getValue("territoryOwner")
  local isMyCamp = data.owner ~= nil and data.owner == Me:getGangId()
  return isMyCamp
end

function Entity:updateTerritoryOwnerEntityEffect()
  if self.territoryEffect == nil or self.territoryEffect[Define.TerritoryEffectType.NormalEffectMyCamp] == nil or self.territoryEffect[Define.TerritoryEffectType.NormalEffect] == nil then
    return
  end
  local isMyCamp = self:isTerritoryMyCamp()
  self:setTerritoryVisible(Define.TerritoryEffectType.NormalEffect, not isMyCamp)
  self:setTerritoryVisible(Define.TerritoryEffectType.NormalEffectMyCamp, isMyCamp)
  self:updateInComeProcessInfo()
  self:updateTerritoryHeadName()
end

function Entity:updateInComeProcessInfo()
  if self.territoryEffect == nil or self.territoryEffect[Define.TerritoryEffectType.InComeEffect] == nil then
    return
  end
  local isMyCamp = self:isTerritoryMyCamp()
  local value = self:getValue("inComeProcessInfo")
  if value.visible and isMyCamp then
    self:setTerritoryVisible(Define.TerritoryEffectType.InComeEffect, true, value)
  else
    self:setTerritoryVisible(Define.TerritoryEffectType.InComeEffect, false)
  end
end

local TerritoryConfig = T(Config, "TerritoryConfig")

function Entity:initTerritoryEffect()
  if self.territoryEffect then
    return
  end
  local entityCfg = self:cfg()
  if entityCfg.territoryId then
    local cfg = TerritoryConfig:getCfgById(entityCfg.territoryId)
    if cfg == nil then
      return
    end
    local effectCfg = {
      [Define.TerritoryEffectType.NormalEffect] = {
        totalTime = nil,
        effectName = cfg.effect,
        num = cfg.effect_cfg.num,
        radius = cfg.effect_cfg.radius,
        yDelta = cfg.effect_cfg.yDelta,
        type = Define.TerritoryEffectType.NormalEffect
      },
      [Define.TerritoryEffectType.NormalEffectMyCamp] = {
        totalTime = nil,
        effectName = cfg.effect_me,
        num = cfg.effect_cfg_me.num,
        radius = cfg.effect_cfg_me.radius,
        yDelta = cfg.effect_cfg_me.yDelta,
        type = Define.TerritoryEffectType.NormalEffectMyCamp
      },
      [Define.TerritoryEffectType.OccupyEffect] = {
        totalTime = cfg.occupy_time,
        effectName = cfg.progress_effect,
        num = cfg.progress_effect_cfg.num,
        radius = cfg.progress_effect_cfg.radius,
        yDelta = cfg.progress_effect_cfg.yDelta,
        type = Define.TerritoryEffectType.OccupyEffect
      },
      [Define.TerritoryEffectType.InComeEffect] = {
        totalTime = cfg.income_time,
        effectName = cfg.income_progress_effect,
        num = cfg.income_progress_effect_cfg.num,
        radius = cfg.income_progress_effect_cfg.radius,
        yDelta = cfg.income_progress_effect_cfg.yDelta,
        type = Define.TerritoryEffectType.InComeEffect
      }
    }
    self.territoryEffect = {}
    for k, v in pairs(effectCfg) do
      self.territoryEffect[k] = TerritoryEffectNode.new(self:getPosition(), v)
    end
    self:updateTerritoryOwnerEntityEffect()
  end
end

function Entity:setTerritoryVisible(type, visible, processInfo)
  if self.territoryEffect == nil or self.territoryEffect[type] == nil then
    return
  end
  self.territoryEffect[type]:setEffectVisible(visible, processInfo)
end

function Entity:onDestroyTerritory()
  if self.territoryEffect == nil then
    return
  end
  for k, v in pairs(self.territoryEffect) do
    v:setEffectVisible(false)
  end
end

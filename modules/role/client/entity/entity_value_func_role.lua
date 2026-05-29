local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:cur_hp(value)
  local maxHP = self:getMaxHp()
  if self.objID == Me.objID then
    self.isInitEnd = value ~= maxHP
  end
  if (self.isInitEnd or self.objID ~= Me.objID) and (self.isPlayer or self:cfg().isTrolley or self.getBastionDefenseType and self:getBastionDefenseType() == Define.Bastion.Defense.Type.Door) then
    self:openPlayerHeadGangIcon()
    self:lightHideTimer()
    self:updateEntityHeadUI({
      progress = {
        visible = true,
        min = value,
        max = maxHP
      }
    })
  end
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_CHANGE_HP, value)
  end
end

function Entity.ValueFunc:max_hp(value)
  self.max_hp = value
end

function Entity:getMaxHp()
  return self.max_hp or 100
end

function Entity:lightHideTimer()
  if self.hideTimer then
    self.hideTimer()
  end
  local time = World.cfg.playerAttrs.lifeBarHideTime * 20
  self.hideTimer = World.LightTimer("hideHp", time, function()
    if self.isValid and self:isValid() then
      self:updateEntityHeadUI({
        progress = {visible = false}
      })
    end
    self.hideTimer = nil
  end)
end

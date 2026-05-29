local GangIconConfig = T(Config, "GangIconConfig")
local gangIconW = 40

function M:init()
  self.imageAreaIconMe = self:child("ImageAreaIconMe")
  self.imageAreaIconEnemy = self:child("ImageAreaIconEnemy")
  self.imageAreaIconNeutral = self:child("ImageAreaIconNeutral")
  self.imageGangIcon = self:child("ImageGangIcon")
end

function M:onOpen()
  self:init()
end

function M:initIcon(cfg)
  self.imageAreaIconMe:setImage(cfg.icon)
  self.imageAreaIconEnemy:setImage(cfg.icon)
  self.imageAreaIconNeutral:setImage(cfg.icon)
  self.imageGangIcon:setArea2({
    0,
    cfg.icon_gang_pos.x
  }, {
    0,
    cfg.icon_gang_pos.y
  }, {0, gangIconW}, {0, gangIconW})
  self.imageGangIcon:setVisible(false)
end

function M:onDataChange(data)
  local owner = data.owner
  if data.name == nil then
    self.imageGangIcon:setVisible(false)
  else
    self.imageGangIcon:setVisible(true)
    local imgPath = GangIconConfig:getGangButtonIcon(data.gangLogoId)
    self.imageGangIcon:setImage(imgPath)
  end
  self.imageAreaIconMe:setVisible(false)
  self.imageAreaIconEnemy:setVisible(false)
  self.imageAreaIconNeutral:setVisible(false)
  if owner == nil then
    self.imageAreaIconNeutral:setVisible(true)
  elseif owner == Me:getGangId() then
    self.imageAreaIconMe:setVisible(true)
  else
    self.imageAreaIconEnemy:setVisible(true)
  end
end

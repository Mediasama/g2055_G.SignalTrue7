local TerritoryConfig = T(Config, "TerritoryConfig")

function M:init()
  self:initUI()
end

function M:initUI()
  self.icon = self:child("Image")
end

function M:initData(data)
  if data then
    local id = data.id
    local cfg = TerritoryConfig:getCfgById(id)
    if cfg then
      self.icon:setImage(cfg.area_icon)
    end
  end
end

M:init()

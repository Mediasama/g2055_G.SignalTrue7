local GoodsBaseConfig = T(Config, "GoodsBaseConfig")

function M:init()
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imageIcon = self:child("ImageIcon")
  self.textName = self:child("TextName")
  self.textDetail = self:child("TextDetail")
  self.imageIcon = self:child("ImageIcon")
  self.actorWindow = self:child("ActorWindow")
  self:child("TextTips"):setText(Lang:toText("pass_card_close_tips"))
end

function M:initEvent()
  function self.Image.onMouseClick()
    self:close()
  end
end

function M:setItemId(id)
  if id then
    local cfg = GoodsBaseConfig:getCfgById(id)
    if cfg then
      self.textName:setText(Lang:toText(cfg.name))
      self.textDetail:setText(Lang:toText(cfg.desc))
      if cfg.ifPicActor == 0 then
        self.imageIcon:setVisible(true)
        self.actorWindow:setVisible(false)
        self.imageIcon:setImage(cfg.detailPic)
      elseif cfg.ifPicActor == 1 then
        self.imageIcon:setVisible(false)
        self.actorWindow:setVisible(true)
        self.actorWindow:setActorName(cfg.detailActor)
        if cfg.detailActorAnim and 0 < string.len(cfg.detailActorAnim) then
          self.actorWindow:setSkillName(cfg.detailActorAnim)
        end
        self.actorWindow:setActorScale(cfg.detailActorScale)
        self.actorWindow:setRotateY(cfg.detailActorRotateY)
      elseif cfg.ifPicActor == 2 then
        self.imageIcon:setVisible(false)
        self.actorWindow:setVisible(true)
        self.actorWindow:setActorName(self:getPreviewActorName())
        if cfg.detailActorAnim and 0 < string.len(cfg.detailActorAnim) then
          self.actorWindow:setSkillName(cfg.detailActorAnim)
        end
        self.actorWindow:setActorScale(cfg.detailActorScale)
        self.actorWindow:setRotateY(cfg.detailActorRotateY)
        local skinK, skinV = next(cfg.detailSkinData)
        if skinK and skinV then
          self.freshTimer = World.Timer(5, function()
            local skin = EntityClient.processSkin(Me:getActorName(), Me:data("skins"))
            skin[skinK] = skinV
            for k, v in pairs(skin) do
              if v == "" then
                self.actorWindow:unloadBodyPart(k)
              else
                self.actorWindow:useBodyPart(k, v)
              end
            end
          end)
        end
      end
    end
  end
end

function M:getPreviewActorName()
  local sex = Me.userDetailData.sex or 1
  if sex == 1 then
    local actorName = Me:cfg().actorName or "g2055_boy.actor"
    return "asset/necessary/player/" .. actorName
  else
    local actorName = Me:cfg().actorGirlName or "g2055_girl.actor"
    return "asset/necessary/player/" .. actorName
  end
end

function M:onClose()
  if self.freshTimer then
    self.freshTimer()
  end
end

M:init()

function M:init()
  self:initUI()
  
  self:initEvent()
end

function M:initUI()
  self.freeItem = UI:openWidget("./UI/pass_card/widget_pass_card_reward_item")
  self:child("PanelFree"):addChild(self.freeItem)
  self.goldItem = UI:openWidget("./UI/pass_card/widget_pass_card_reward_item")
  self:child("PanelGold"):addChild(self.goldItem)
  self.levelItem = UI:openWidget("./UI/pass_card/widget_pass_card_level_item")
  self:child("PanelCardLevel"):addChild(self.levelItem)
end

function M:initEvent()
end

function M:initData(data)
  if not data then
    return
  end
  self.freeItem:initData({isGold = false, passCardData = data})
  self.goldItem:initData({isGold = true, passCardData = data})
  self.levelItem:initData({isGold = false, passCardData = data})
end

M:init()

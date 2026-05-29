local widget_base = require("ui.widget.widget_base")
local WidgetCurrencyItem = Lib.derive(widget_base)
local areaCfg = {
  shop = {
    gold = {x = -0.174219, y = 0.0125},
    gDiamond = {x = -0.009375, y = 0.0125}
  }
}

function WidgetCurrencyItem:init(type)
  widget_base.init(self, "CurrencyItem.json")
  self._allEvent = {}
  self.lastGoldCount = -1
  self:initUI()
  self:initEvent()
  self:setType(type)
end

function WidgetCurrencyItem:initUI()
  self.imgBG = self:child("CurrencyItem-BG")
  self.btnShop = self:child("CurrencyItem-shop")
  self.btnGDiamondsBg = self:child("CurrencyItem-gDiamondsBg")
  self.imgGDiamondsImg = self:child("CurrencyItem-gDiamondsImg")
  self.txtGDiamondsTxt = self:child("CurrencyItem-gDiamondsTxt")
  self.btnGold = self:child("CurrencyItem-gold")
  self.imgGoldTxt = self:child("CurrencyItem-goldTxt")
  self.txtGoldImg = self:child("CurrencyItem-goldImg")
  self.imgAdd2 = self:child("CurrencyItem-addImg2")
  self.imgAdd1 = self:child("CurrencyItem-addImg1")
  self.btnShop:SetVisible(true)
  self:changeCurrency()
end

function WidgetCurrencyItem:initEvent()
  self:subscribe(self.btnShop, UIEvent.EventButtonClick, function()
  end)
  self:subscribe(self.btnGDiamondsBg, UIEvent.EventButtonClick, function()
    Interface.onRecharge(1)
  end)
  self:subscribe(self.btnGold, UIEvent.EventButtonClick, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
    self:changeCurrency()
  end)
end

function WidgetCurrencyItem:setType(type)
  if type == Define.CurrencyItemType.shop then
    self.btnShop:SetVisible(false)
    self.btnShop:SetTouchable(false)
    self.btnGDiamondsBg:SetArea({
      areaCfg.shop.gDiamond.x,
      0
    }, {
      areaCfg.shop.gDiamond.y,
      0
    }, {
      0,
      self.btnGDiamondsBg:GetWidth()[2]
    }, {
      0,
      self.btnGDiamondsBg:GetHeight()[2]
    })
    self.btnGold:SetArea({
      areaCfg.shop.gold.x,
      0
    }, {
      areaCfg.shop.gold.y,
      0
    }, {
      0,
      self.btnGold:GetWidth()[2]
    }, {
      0,
      self.btnGold:GetHeight()[2]
    })
  end
end

function WidgetCurrencyItem:hideShopBtn()
  self.btnShop:SetVisible(false)
end

function WidgetCurrencyItem:changeCurrency()
  local wallet = Me:data("wallet")
  if not next(wallet) then
    return
  end
  if wallet.gDiamonds then
    self.txtGDiamondsTxt:SetText(Plugins.CallTargetPluginFunc("engine_overwrite", "toBigIntegerString", math.floor(wallet.gDiamonds.count)))
  end
  local gold = math.floor(wallet.gold.count or 0)
  self.imgGoldTxt:SetText(Plugins.CallTargetPluginFunc("engine_overwrite", "toBigIntegerString", gold))
end

function WidgetCurrencyItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetCurrencyItem

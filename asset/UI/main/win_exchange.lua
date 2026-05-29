local ExchangeConfig = T(Config, "ExchangeConfig")

function M:init()
  self.progressStep = 0
  self.curCfgItemIndex = 0
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.progressStep = ExchangeConfig:getItemNum() <= 1 and 0 or 1 / (ExchangeConfig:getItemNum() - 1)
  self.textCubeNum = self:child("TextCubeNum")
  self.textMoneyNum = self:child("TextMoneyNum")
  self.btnClose = self:child("ButtonClose")
  self.btnYes = self:child("ButtonYes")
  self.btnNo = self:child("ButtonNo")
  self.btnAdd = self:child("ButtonAdd")
  self.btnReduce = self:child("ButtonReduce")
  self.slider = self:child("SliderAmount")
  self.slider:setClickStep(self.progressStep)
  self:child("TextTitle"):setText(Lang:toText("exchange.title"))
  self:child("ButtonYes"):setText(Lang:toText("exchange.yes"))
  self:child("ButtonNo"):setText(Lang:toText("exchange.no"))
  self:initProgress()
  World.Timer(1, function()
    local thumb = self.slider:getThumb()
    thumb:setClippedByParent(false)
    thumb:setWidth({0, 19})
    thumb:setHeight({0, 50})
  end)
end

function M:initEvent()
  function self.btnClose.onMouseClick()
    self:close()
  end
  
  function self.btnNo.onMouseClick()
    self:close()
  end
  
  function self.btnAdd.onMouseClick()
    if self.progressStep > 0 then
      self:sliderChange(true)
    end
  end
  
  function self.btnReduce.onMouseClick()
    if self.progressStep > 0 then
      self:sliderChange(false)
    end
  end
  
  function self.btnYes.onMouseClick()
    if self.curCfgItemIndex > 0 then
      self:exchange()
    else
      self:close()
    end
  end
  
  function self.slider.onSliderValueChanged(instance)
    if self.progressStep > 0 then
      self.curCfgItemIndex = math.floor(instance:getCurrentValue() / self.progressStep) + 1
      self:updateGoodsNum()
    end
  end
end

function M:sliderChange(isAdd)
  if self.progressStep > 0 then
    if isAdd then
      self.slider:setCurrentValue(self.slider:getCurrentValue() + self.progressStep)
    else
      self.slider:setCurrentValue(math.max(self.slider:getCurrentValue() - self.progressStep, 0))
    end
  end
end

function M:updateGoodsNum()
  local cfg = ExchangeConfig:getCfgByIndex(self.curCfgItemIndex)
  if cfg then
    self.textCubeNum:setText(tostring(cfg.cost))
    self.textMoneyNum:setText(tostring(cfg.num))
    local currency_before = Me:getCurrencyByName(Define.CURRENCY_TYPE.gold)
    local config = World.cfg.bastionSetting or {}
    local vault = config.vault or {}
    local maxBalance = vault.maxBalance or 99999999
    if maxBalance <= currency_before + cfg.num then
      self.btnYes:setEnabled(false)
    else
      self.btnYes:setEnabled(true)
    end
  else
    self.textCubeNum:setText(tostring(0))
    self.textMoneyNum:setText(tostring(0))
  end
end

function M:initProgress()
  self.slider:setCurrentValue(0)
  self.curCfgItemIndex = 1
  self:updateGoodsNum()
end

function M:exchange()
  local wallet = Me:data("wallet")
  local cfg = ExchangeConfig:getCfgByIndex(self.curCfgItemIndex)
  if not cfg then
    Lib.logError("win_exchange:buy(),item cfg not found,index:", self.curCfgItemIndex)
    return
  end
  local cost = cfg.cost
  if not cost then
    Lib.logError("win_exchange:buy(),cost not found,index:", self.curCfgItemIndex)
    return
  end
  if wallet and wallet.gDiamonds and cost <= wallet.gDiamonds.count then
    Me:sendPacket({
      pid = "ExchangeMoney",
      idx = self.curCfgItemIndex
    })
    self:close()
  else
    Interface.onRecharge(1)
  end
end

M:init()

local WinTattoo = M
local ClothesConfig = T(Config, "ClothesConfig")

function WinTattoo:init()
  self.textPrice = self:child("TextPrice")
  self.imageStartTattoo = self:child("ImageStartTattoo")
  self.imagePriceBg = self:child("ImagePriceBg")
  self.baseWindow = self:child("DefaultWindow")
  self:child("Text"):setText(Lang:toText("name.shop.Tattoo"))
  self:initButton()
  self:initEvent()
end

function WinTattoo:stopOnTattooSound()
  if self.onTattooSound and self.onTattooSound then
    Me:stopSound(self.onTattooSound)
    self.onTattooSound = nil
  end
end

function WinTattoo:initButton()
  self:child("Image").onMouseClick = function()
    if self.waitResponse then
      return
    end
    Me:playSoundByKey("g2055_commonButtonSound")
    self.waitResponse = true
    if self:isEmptyTattoo() then
      Me:showTattooErrorTips(Define.TattooPacketCode.Empty)
    else
      local cfg = ClothesConfig:getCfgById(self.tattooData.id)
      if Me:getCurrencyById(cfg.currencyType) < cfg.price then
        Me:showTattooErrorTips(Define.TattooPacketCode.NoEnoughMoney)
        return
      end
      self:hideAllUI(true)
      Me:requestTattoo(self.objID, self.tattooData.id, function(code)
        if code ~= Define.TattooPacketCode.Success then
          self:hideAllUI(false)
        else
          Me:playSoundByKey("g2055_commonBuySound")
          self.onTattooSound = Me:playSoundByKey("g2055_tattooSound")
        end
        self.waitResponse = false
      end)
    end
  end
end

function WinTattoo:hideAllUI(hide)
  if hide then
    if self.showFun == nil then
      self.baseWindow:setVisible(false)
      self.showFun = UI:hideOpenedWnd()
      Lib.showScreenMask(true)
    end
  else
    if self.showFun then
      self.baseWindow:setVisible(true)
      self.showFun()
      self.showFun = nil
      Lib.showScreenMask(false)
    end
    self:stopOnTattooSound()
  end
end

function WinTattoo:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_NEW_TATTOO_DATA, function(param)
    if param and self.objID == param.objID then
      self:hideAllUI(false)
      self.tattooData = param.data
      self.objID = param.objID
      self:initView()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TATTOO_INTERRUPT, function()
    self:hideAllUI(false)
  end)
end

function WinTattoo:initView()
  if self:isEmptyTattoo() then
    self.imagePriceBg:setVisible(false)
  else
    self.imagePriceBg:setVisible(true)
    local cfg = ClothesConfig:getCfgById(self.tattooData.id)
    self.textPrice:setText(cfg.price)
  end
  self.imageStartTattoo:setVisible(true)
end

function WinTattoo:onOpen(param)
  if param then
    self.tattooData = param.data
    self.objID = param.objID
  end
  self:init()
  self:initView()
end

function WinTattoo:isEmptyTattoo()
  if self.tattooData == nil or self.tattooData.id == nil or self.objID == nil then
    return true
  end
  return false
end

function WinTattoo:onClose()
  self:hideAllUI(false)
  self:stopOnTattooSound()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

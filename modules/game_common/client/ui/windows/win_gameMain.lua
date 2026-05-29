local WinGameMain = M

function WinGameMain:init()
  WinBase.init(self, "GameMain.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinGameMain:initData()
  self.ratio = UIMgr.UIShowManage:getAdapterRatio()
end

function WinGameMain:initUI()
  self.btnSetting = self:child("GameMain-btnSetting")
  self.lytActionControlNode = self:child("GameMain-actionControlNode")
  self.btnShop = self:child("GameMain-btnShop")
  self:addGM()
  self:addActionControl()
end

function WinGameMain:addGM()
  if not World.gameCfg.gm then
    return
  end
  local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "Button_GM")
  btn:SetNormalImage("set:add_sub.json image:add")
  btn:SetPushedImage("set:add_sub.json image:add")
  btn:SetArea({0.5, 0}, {0, 100}, {0, 50}, {0, 50})
  self:root():AddChildWindow(btn)
  self:subscribe(btn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end)
end

function WinGameMain:initEvent()
  self:subscribe(self.btnSetting, UIEvent.EventButtonClick, function()
    UI:openWnd("setting")
  end)
end

function WinGameMain:subscribeEvent()
end

function WinGameMain:addActionControl()
  local actionControlWin = UI:openWnd("actionControl")
  local actionControlRoot = actionControlWin:root()
  actionControlRoot:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytActionControlNode:AddChildWindow(actionControlRoot)
end

function WinGameMain:initView()
end

function WinGameMain:onHide()
  UI:closeWnd("GameMain")
end

function WinGameMain:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("GameMain")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGameMain:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function WinGameMain:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinGameMain

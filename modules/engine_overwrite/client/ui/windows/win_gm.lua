local WinGM = M

function WinGM:init()
  WinBase.init(self, "GM.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinGM:initUI()
  self:addGM()
end

function WinGM:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_GM_BTN, function()
    self:addGM(true)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_GMBOARD, function()
    UI:openWnd("gm")
  end)
end

function WinGM:subscribeEvent()
end

function WinGM:refreshGMList()
  if self._gmRoot then
      self:root():RemoveChildWindow(self._gmRoot)
  end

  self._gmRoot = GUIWindowManager.instance:CreateGUIWindow1("DefaultWindow", "GMRoot")
  self._gmRoot:SetArea({0.1, 0}, {0.1, 0}, {0.8, 0}, {0.8, 0})
  self:root():AddChildWindow(self._gmRoot)

  local bg = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "GMBG")
  bg:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  bg:SetImage("gameres|asset/Texture/Gui/def_image.png")
  bg:SetAlpha(0.8)
  self._gmRoot:AddChildWindow(bg)

  local closeBtn = GUIWindowManager.instance:CreateGUIWindow1("Button", "GMCloseBtn")
  closeBtn:SetArea({1, -50}, {0, 10}, {0, 40}, {0, 40})
  closeBtn:SetText("X")
  self._gmRoot:AddChildWindow(closeBtn)
  self:subscribe(closeBtn, UIEvent.EventButtonClick, function()
      self:onHide()
  end)

  local gm_client = require("gm_client")
  local y = 50
  local count = 0

  -- Sort keys to have a predictable list
  local keys = {}
  for name in pairs(gm_client) do table.insert(keys, name) end
  table.sort(keys)

  for _, name in ipairs(keys) do
    local func = gm_client[name]
    if type(func) == "function" then
      count = count + 1
      local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "GM_Btn_" .. count)
      btn:SetArea({0, 20}, {0, y}, {1, -40}, {0, 35})
      -- Clean up name if it has lots of escape characters/categories
      local displayName = name:gsub("^.*/", "")
      btn:SetText(tostring(name))
      self._gmRoot:AddChildWindow(btn)
      self:subscribe(btn, UIEvent.EventButtonClick, function()
        func(Me)
      end)
      y = y + 40
    end
  end

  -- Also add a "Close" button at the bottom just in case
  y = y + 10
  local finalClose = GUIWindowManager.instance:CreateGUIWindow1("Button", "GMFinalClose")
  finalClose:SetArea({0.2, 0}, {0, y}, {0.6, 0}, {0, 40})
  finalClose:SetText("CLOSE PANEL")
  self._gmRoot:AddChildWindow(finalClose)
  self:subscribe(finalClose, UIEvent.EventButtonClick, function()
      self:onHide()
  end)
end

function WinGM:addGM(isMust)
  if self.btn then
    return
  end
  if not World.gameCfg.gm and not isMust then
    return
  end
  local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "Button_GM")
  btn:SetNormalImage("set:add_sub.json image:add")
  btn:SetPushedImage("set:add_sub.json image:add")
  btn:SetArea({0.5, 0}, {0, 692}, {0, 30}, {0, 30})
  self:root():AddChildWindow(btn)
  self:subscribe(btn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end)
  self.btn = btn
end

function WinGM:onHide()
  UI:closeWnd("gm")
end

function WinGM:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("gm")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGM:onOpen()
  self:subscribeEvent()
  self:refreshGMList()
end

function WinGM:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinGM

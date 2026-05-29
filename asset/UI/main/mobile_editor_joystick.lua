local util = require("common.util.util")
self.axisSize = M.Axis:getSize()
self.axisRadius = self.axisSize.width[2] * 0.5
self.poleSize = M.Axis.Pole:getSize()
self.polRadius = self.poleSize.width[2] * 0.5
self.poleMaxSize = self.axisRadius - self.polRadius

function M.Axis.Background.onMouseButtonDown(instance, window, x, y)
  Lib.logDebug("M.Axis.onMouseButtonDown")
  self:move(x, y)
end

function M.Axis.Background.onMouseMove(instance, window, x, y)
  Lib.logDebug("M.Axis.onMouseMove")
  self:move(x, y)
end

function M.Axis.Background.onMouseButtonUp(instance, window, x, y)
  Lib.logDebug("M.Axis.onMouseButtonUp")
  self:reset()
end

function M.Axis.Pole.onMouseButtonDown(instance, window, x, y)
  self:move(x, y)
end

function M.Axis.Pole.onMouseMove(instance, window, x, y)
  self:move(x, y)
end

function M.Axis.Pole.onMouseButtonUp(instance, window, x, y)
  self:reset()
end

function M:move(x, y)
  local dx = CEGUICoordConverter.screenToWindowX1(M.Axis:getWindow(), x) - self.axisRadius
  local dy = CEGUICoordConverter.screenToWindowY1(M.Axis:getWindow(), y) - self.axisRadius
  local sqrtDistance = dx * dx + dy * dy
  sqrtDistance = sqrtDistance ~= 0 and sqrtDistance or 1
  if sqrtDistance > self.poleMaxSize * self.poleMaxSize then
    local ratio = math.sqrt(self.poleMaxSize * self.poleMaxSize / sqrtDistance)
    dx = dx * ratio
    dy = dy * ratio
    sqrtDistance = self.poleMaxSize * self.poleMaxSize
  end
  M.Axis.Pole:setPosition(UDim2.new(0, dx, 0, dy))
  local poleForward = -dy / math.sqrt(sqrtDistance)
  local poleStrafe = -dx / math.sqrt(sqrtDistance)
  if poleForward < -0.9 then
    poleForward = -1
    poleStrafe = 0
  end
  Blockman.Instance().gameSettings.poleForward = poleForward
  Blockman.Instance().gameSettings.poleStrafe = poleStrafe
  if Me.weapon then
    local conf = World.cfg.moveSpeed
    local rate = Me.isHurtCutSpeed and World.cfg.hurtCutSpeed.rate or 1
    if 0 < poleForward and math.abs(poleStrafe) < 0.75 then
      if Me.speedState ~= Define.SPEED_STATE.UP then
        local speedRate, accRate = Me.weapon:getMoveSpeed()
        local moveSpeed = conf.upMoveSpeed * speedRate * rate
        local moveAcc = conf.upMoveAcc * accRate
        Me:sendPacket({
          pid = "sendBeginMoveSpeed",
          moveSpeed = moveSpeed,
          moveAcc = moveAcc
        })
        Me.speedState = Define.SPEED_STATE.UP
      end
    elseif Me.speedState ~= Define.SPEED_STATE.DOWN then
      local speedRate, accRate = Me.weapon:getMoveSpeed()
      local moveSpeed = conf.downMoveSpeed * speedRate
      local moveAcc = conf.downMoveAcc * accRate
      Me:sendPacket({
        pid = "sendBeginMoveSpeed",
        moveSpeed = moveSpeed,
        moveAcc = moveAcc
      })
      Me.speedState = Define.SPEED_STATE.DOWN
    end
  end
end

function M:reset()
  M.Axis.Pole:setPosition(UDim2.new(0, 0, 0, 0))
  Blockman.Instance().gameSettings.poleForward = 0
  Blockman.Instance().gameSettings.poleStrafe = 0
end

function M:subscribeEvents()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UNLOCK_FLY_MODE, function()
    M.BtnFly:setEnabled(true)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LOCK_FLY_MODE, function()
    M.BtnFly:setEnabled(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_CAPTURE, function()
    M.BtnCapture:setVisible(true)
    M.BtnCapture:setEnabled(true)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HIDE_CAPTURE, function()
    M.BtnCapture:setVisible(false)
    M.BtnCapture:setEnabled(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HIDE_JOYSTICK, function(b)
    M.hideOrShowUI(b)
  end)
end

function M:initGangBtn()
  self.imageOpenGang = self:child("ImageOpenGang")
  self.updateRedDot = self:child("ImageGangUpdateRedDot")
  self.buttonOpenGang = self:child("ButtonOpenGang")
  self.buttonOpenTerritoryMap = self:child("ButtonOpenTerritoryMap")
  self.buttonPlayerMotion = self:child("ButtonPlayerMotion")
  self.buttonStopMotion = self:child("Button_stop_motion")
  self.textCubeNum = self:child("TextCubeNum")
  self.buttonStopMotion:setVisible(false)
  self.imageGangGreenArrow = self:child("ImageGangGreenArrow")
  
  function self.buttonOpenGang.onMouseClick()
    Lib.openWindow("./UI/gang/win_gang")
    Me:requestGangsData()
    self.updateRedDot:setVisible(false)
  end
  
  function self.buttonOpenTerritoryMap.onMouseClick()
    if not self.mapWin then
      self.mapWin = UI:openWidget("./UI/territory/win_territory_map")
      M.mapParentWindow:addChild(self.mapWin)
    else
      self.mapWin:setVisible(true)
      self.mapWin:onOpen()
    end
  end
  
  function self.buttonPlayerMotion.onMouseClick()
    UI:openWindow("./UI/player_motion/win_player_motion")
  end
  
  function self.buttonStopMotion.onMouseClick()
    Me:pam_C2S_RequestStopMotion()
  end
  
  if self._allEvent == nil then
    self._allEvent = {}
  end
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REFRESH_GANG_OPEN_VIEW_BUTTON, function()
    self:updateOpenGangImg()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_GANG_APPLY_LIST, function(visible)
    self.updateRedDot:setVisible(visible)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UI_CLOSE_MINIMAP, function()
    if self.mapWin then
      self.mapWin:onClose()
      self.mapWin:setVisible(false)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UI_OPEN_DEAD, function(data)
    self:openDeadWin(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UI_CLOSE_DEAD, function(data)
    self:closeDeadWin()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UI_OPEN_CHAT_MINI, function(data)
    self:openWinChatMini()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PAM_MOTION_CHANGED, function(data)
    local motionId = Me:pam_getMotionID()
    self.buttonStopMotion:setVisible(motionId ~= 0)
  end)
  World.Timer(20, function()
    return not self:resetCubeNum()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PLAYER_OUT_HOME, function()
    self:initGangGreenArrow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_OPEN_GANG_WIN, function()
    self:hideGangGreenArrow()
  end)
end

function M:updateOpenGangImg()
  local icon = Me:getGangButtonIcon()
  self.imageOpenGang:setImage(icon)
end

function M:initGangGreenArrow()
  if Me.gangGreenButtonArrowShowed then
    return
  end
  Me.gangGreenButtonArrowShowed = true
  self.imageGangGreenArrow:setVisible(true)
  self.imageGangGreenArrowInitX = self.imageGangGreenArrow:getXPosition()[2]
  self.imageGangGreenArrowOffsetX = 0
  self.imageGangGreenArrowDir = 1
  self.imageGangGreenArrowStep = 3
  self.imageGangGreenArrowRange = 15
  self.greenArrowTimer = World.Timer(1, function()
    local newX = self.imageGangGreenArrowInitX + self.imageGangGreenArrowOffsetX
    self.imageGangGreenArrow:setXPosition({0, newX})
    self.imageGangGreenArrowOffsetX = self.imageGangGreenArrowOffsetX + self.imageGangGreenArrowStep * self.imageGangGreenArrowDir
    if self.imageGangGreenArrowOffsetX > self.imageGangGreenArrowRange or self.imageGangGreenArrowOffsetX < -self.imageGangGreenArrowRange then
      self.imageGangGreenArrowDir = -self.imageGangGreenArrowDir
    end
    return true
  end)
end

function M:hideGangGreenArrow()
  if not Me.gangGreenButtonArrowShowed then
    return
  end
  self.imageGangGreenArrow:setVisible(false)
  self.greenArrowTimer()
end

function M:onOpen(params)
  self:setUsingAutoRenderingSurface(true)
  local str = Me:getCurrencyById(Define.CURRENCY_ID.gold)
  self.DefaultWindow.PanelMoney.Text:setText(str)
  Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function(data)
    local count = Me:getCurrencyById(Define.CURRENCY_ID.gold)
    if self.oldMoneyCount and count > self.oldMoneyCount then
      Me:playSoundByKey("g2055_item_pickMoney")
    end
    if not self.oldMoneyCount then
      self.DefaultWindow.PanelMoney.Text:setText(count)
      self.oldMoneyCount = count
      return
    end
    local flytextInterval = World.cfg.goldAddEffectTime
    if self.goldEffectTimer then
      self.goldEffectTimer()
    end
    self.goldEffectTimer = World.LightTimer("goldEffectTimer", flytextInterval, function()
      self.DefaultWindow.PanelMoney.Text:setText(count)
      self.DefaultWindow.PanelMoney.TextAdd:setText("")
      self.oldMoneyCount = count
    end)
    local addCount = count - self.oldMoneyCount
    if addCount ~= 0 then
      if 0 < addCount then
        addCount = "+" .. addCount
      end
      self.DefaultWindow.PanelMoney.TextAdd:setText(addCount)
    end
  end)
  
  function self.Button.onMouseClick()
    local settingWnd = UI:isOpenWindow("setting")
    if settingWnd then
      settingWnd:setVisible(not settingWnd:isVisible())
    else
      settingWnd = UI:openSystemWindow("setting")
    end
    Lib.emitEvent(Event.EVENT_ONLINE_ROOM_SHOW, not settingWnd:isVisible())
    Me.weapon:updateCamera()
  end
  
  function self.Button_frend.onMouseClick()
    local PlayerList = UI.root.playerList
    PlayerList = PlayerList or UI:openSystemWindow("playerList")
    PlayerList:setVisible(not PlayerList:isVisible())
  end
  
  function self.Button_video.onMouseClick()
    Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", true)
  end
  
  function self.DefaultWindow.PanelMoney.ButtonAdd.onMouseClick()
    Lib.openWindow("./UI/main/win_exchange")
  end
  
  function self.DefaultWindow.PanelCube.ButtonAddCube.onMouseClick()
    Interface.onRecharge(1)
  end
  
  self:initPassCardUI()
  Lib.subscribeEvent(Event.EVENT_ENTER_UNLOCK_DOOR, function()
    M.Axis:setVisible(false)
    self.isLock = true
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_UNLOCK_CAR, function()
    M.Axis:setVisible(true)
    self.isLock = false
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_UNLOCK_DOOR, function()
    M.Axis:setVisible(true)
    self.isLock = false
  end)
  Lib.subscribeEvent(Event.CUBE_NUM_CHANGE, function()
    self:resetCubeNum()
  end)
  self:initGangBtn()
  Me.mainUIWin = self
  self:initPlayerCircleTips()
  self:initGangRank()
end

function M:initPlayerCircleTips()
  self:child("PanelPlayerCircleTips"):addChild(UI:openWidget("./UI/main/widget_player_circle_tips"))
end

function M:initGangRank()
  self:child("PanelPlayerCircleTips"):addChild(UI:openWidget("./UI/gang/win_gang_rank"))
end

function M:initPassCardUI()
  self.buttonPassCard = self:child("ButtonPassCard")
  
  function self.buttonPassCard.onMouseClick()
    local state = Me:getCurState()
    if state ~= Define.CHARACTER_STATE_TYPE.GROUND and state ~= Define.CHARACTER_STATE_TYPE.DIE then
      Me:sendPacket({
        pid = "isPassCardDateC2S"
      }, function(ret)
        if ret then
          Lib.openWindow("./UI/pass_card/win_pass_card")
        else
          Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("passCard.not.open"))
        end
      end)
    else
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("passCard.cant.open.ui"))
    end
  end
  
  self.buttonPassCard:setVisible(false)
  Me:sendPacket({
    pid = "isPassCardDateC2S"
  }, function(ret)
    self.buttonPassCard:setVisible(true)
    if ret then
      self.buttonPassCard.ImageRedDot:setVisible(Me:checkPassCardCanGetReward())
      self:resetPassCardLevel(true)
    else
      self.buttonPassCard.ImageRedDot:setVisible(false)
      self:resetPassCardLevel(false)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_PASS_CARD_LEVEL_UP, function()
    self:resetPassCardLevel(true)
    self.buttonPassCard.ImageRedDot:setVisible(Me:checkPassCardCanGetReward())
  end)
  Lib.subscribeEvent(Event.EVENT_PASS_CARD_GET_REWARD, function()
    self.buttonPassCard.ImageRedDot:setVisible(Me:checkPassCardCanGetReward())
  end)
  Lib.subscribeEvent(Event.EVENT_PASS_CARD_BUY_GOLD_CARD, function()
    self.buttonPassCard.ImageRedDot:setVisible(Me:checkPassCardCanGetReward())
  end)
end

function M:onClose(params)
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function M:resetCubeNum()
  local wallet = Me:data("wallet")
  if wallet and wallet.gDiamonds and wallet.gDiamonds.count then
    self.textCubeNum:setText(tostring(wallet.gDiamonds.count))
    print("------------------------------------  resetCubeNum  ", wallet.gDiamonds.count)
    return true
  end
  print("++++++++++++++++++-++++++++++++++++++++  resetCubeNum nil ")
  return false
end

function M:resetPassCardLevel(isPassCardDate)
  if not isPassCardDate then
    self.buttonPassCard.TextLevel:setText("")
  else
    local passCard = Me:getPlayerPassCard()
    if passCard and passCard.level then
      self.buttonPassCard.TextLevel:setText(Me:playerPassCardMaxLevel() and "MAX" or "LV." .. passCard.level)
    end
  end
end

function M:openDeadWin(data)
  if not self.deadWin then
    self.deadWin = UI:openWidget("UI/be_dead")
    M.deadParentWindow:addChild(self.deadWin)
  else
    self.deadWin:setVisible(true)
  end
  self.deadWin:onOpen(data)
  M.Axis:setVisible(false)
  if self.mapWin then
    self.mapWin:onClose()
    self.mapWin:setVisible(false)
  end
end

function M:closeDeadWin(data)
  if self.deadWin then
    self.deadWin:setVisible(false)
  end
  M.Axis:setVisible(true)
end

function M:openWinChatMini()
  M.chartParentWindow:addChild(UI:openWidget("./UI/new_chat/gui/win_chat_mini"))
end

function M:hideOrShowUI(b)
  if b then
    self.Axis:setAlpha(1)
  else
    Me.joystickWin:show()
    self.Axis:setAlpha(0)
  end
  self.Button:setVisible(b)
  self.Button_frend:setVisible(b)
  self.Button_video:setVisible(b)
  self.DefaultWindow:setVisible(b)
  if b and Me:isDriving() then
    Lib.openWindow("./UI/vehicle/win_vehicle_ctrl")
    Lib.emitEvent(Event.EVENT_RIDE_ON_CAR)
  end
end

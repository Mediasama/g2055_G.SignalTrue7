local GameReport = T(Game, "Report")

function Player:insertCommonData(defaultData)
  defaultData.player_coins = self:getCurrencyById(3)
  local info = self:getValue("playerActive")
  if info then
    defaultData.player_active = info.activeType or 1
  else
    defaultData.player_active = 1
  end
  local pos = self:getPosition()
  defaultData.coordinate = string.format("%.2f,%.2f,%.2f", pos.x, pos.y, pos.z)
  defaultData.team_id_g2055 = self:getGangId() or ""
  defaultData.battle_id = self:getValue("battle_id")
  defaultData.player_game_time = self:getCurrentTotalGameTime()
  defaultData.server_id = self:getValue("game_id")
  defaultData.cloth_id_g2055 = self:getWearingClothesReportData()
  defaultData.area_id = self:getAreaID()
  defaultData.arms_id = self.weapon and self.weapon.id or 0
  defaultData.car_id = self:getCurCarId() or -1
  if World.isClient then
    defaultData.bullet_num = self:getMainBulletCount()
  else
    defaultData.bullet_num = self.weapon and self.weapon:getBulletCount() or 0
  end
end

function Player:evt_reportEvent(type, defaultData, isInsertCommonData)
  if isInsertCommonData == nil then
    isInsertCommonData = true
  end
  if isInsertCommonData then
    self:insertCommonData(defaultData)
  end
  GameReport:report(type, defaultData, self)
end

function Player:evt_reportWinOpen(uiName)
  self:evt_reportUIEvent(Event.EVENT_OPEN_WINDOW, uiName)
end

function Player:evt_reportWinClose(uiName)
  self:evt_reportUIEvent(Event.EVENT_CLOSE_WINDOW, uiName)
end

function Player:evt_reportUIEvent(event, uiName)
  if not World.isClient or not self:evt_isLogin() then
    return
  end
  if event == Event.EVENT_OPEN_WINDOW then
    if self.uiTimeKey == nil then
      self.uiTimeKey = {}
    end
    if self.uiTimeKey[uiName] then
      return
    end
    if self.uiTimeKey[uiName] == nil then
      self.uiTimeKey[uiName] = os.time()
    end
    self:evt_reportEvent("uiOpen", {name = uiName})
  elseif event == Event.EVENT_CLOSE_WINDOW then
    if self.uiTimeKey == nil then
      return
    end
    if self.uiTimeKey[uiName] then
      local time = os.time() - self.uiTimeKey[uiName]
      self:evt_reportEvent("uiClose", {name = uiName, time = time})
      self.uiTimeKey[uiName] = nil
    end
  end
end

function Player:evt_reportCoinChange(amount, currency_before, exchange_source, coins_type, currency_type)
  if coins_type == nil then
    coins_type = Define.CoinsPos.Body
  end
  local currency_after = 0
  local currency_id = Coin:getCoinId(Define.CURRENCY_TYPE.gold)
  if World.isClient then
    currency_after = Me:getCurrencyById(currency_id)
  else
    currency_after = self:getCurrencyById(currency_id)
  end
  local change_type = 1
  if 0 < amount then
    change_type = 0
  end
  local data = {
    currency_id = currency_id,
    change_type = change_type,
    amount = amount,
    currency_before = currency_before,
    currency_after = currency_after,
    exchange_source = exchange_source,
    currency_type = currency_type
  }
  self:evt_reportEvent("app_sc_exchange", data)
end

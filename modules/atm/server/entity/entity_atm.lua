local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local AtmConfig = T(Config, "AtmConfig")
local BattleFieldManager = require("server.battle_field_manager")
local battleField

function EntityServer:dropMoney(dropAllMoney)
  if self:getATMState() ~= Define.ATM_STATE.ST_NORMAL or self:getATMCurMoney() < 1 then
    return
  end
  local cfg = AtmConfig:getCfgById(self:getATMCfgId())
  if not cfg or os.time() - self:getATMDropStamp() < cfg.loot_cd then
    return
  end
  if battleField == nil then
    battleField = BattleFieldManager:getMatchBattleFiled()
  end
  local minR = self:cfg().dropMinR
  local maxR = self:cfg().dropMaxR
  local R = math.random(minR, maxR) / 10
  local clonePosition = Vector3.new(0, 0, R)
  local yaw = -self:getRotationYaw()
  local rotation = Vector3.new(0, math.random(-90, 90) + yaw, 0)
  Lib.rotate(clonePosition, rotation)
  local pos = self:getPosition() + clonePosition
  local count = self:calDropMoneyCount(dropAllMoney)
  local item = battleField:createDrop(pos, Define.GoldItemID, count, nil, nil, Define.ItemDataDropState.SystemDrop)
  if item then
    item.itemData.isATM = true
  end
  self:setATMCurMoney(self:getATMCurMoney() - count)
  self:setATMDropStamp(os.time())
end

function EntityServer:calDropMoneyCount(dropAllMoney)
  local count = 1
  local cfg = AtmConfig:getCfgById(self:getATMCfgId())
  if not cfg then
    return
  end
  if dropAllMoney then
    count = self:getATMCurMoney()
  else
    count = math.min(self:getATMCurMoney(), math.random(cfg.loot_min, cfg.loot_max))
  end
  return math.floor(count)
end

function EntityServer:checkATMState()
  if self:getATMCurMoney() <= 0 then
    self:setATMState(Define.ATM_STATE.ST_DEAD)
  end
end

function EntityServer:playAMTAction(actionName)
  self:setActionIdle(actionName)
end

World.Timer(1, function()
  Lib.subscribeEvent(Event.EVENT_ENTITY_DEATH, function(objId, obj)
    if obj and obj:isValid() and obj:cfg().isATM then
      obj:onATMDie()
    end
  end)
end)

function EntityServer:onATMDie()
  if not self:isValid() or not self:cfg().isATM then
    return
  end
  if self:cfg().ATMType == Define.ATM_TYPE.ATM_NPC then
    self:dropMoney(true)
  end
  self:setATMState(Define.ATM_STATE.ST_DEAD)
end

function EntityServer:ATMRevive()
  local cfg = AtmConfig:getCfgById(self:getATMCfgId())
  if cfg then
    self:setATMState(Define.ATM_STATE.ST_NORMAL)
    self:setCurHp(self.max_hp)
    self:setATMCurMoney(cfg.all_money)
    self:setIsDead(false)
    self._isDoDie = false
  end
end

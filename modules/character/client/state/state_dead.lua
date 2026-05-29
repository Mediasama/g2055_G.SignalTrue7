local StateDead = Lib.class("StateDead", require("common.state.state_base"))

function StateDead:enter(param)
  print("StateDead:enter(param), client")
  self.entity:setActionMapping("idle", "g2055_dead_1")
  self.entity:refreshUpperAction()
  Lib.emitEvent(Event.EVENT_RESET_ITEM_SELECT)
  Blockman.instance:control().enable = false
  local name, attackObjID = self.entity:getHurtEnemyName()
  local data = {}
  data.who = name
  data.weaponName = ""
  Lib.emitEvent(Event.EVENT_UI_OPEN_DEAD, data)
  Me:playSoundByKey("g2055_battle_getKilled")
  local attackEntity = World.CurWorld:getEntity(attackObjID)
  self.entity:setKillEnemy(attackEntity)
end

function StateDead:update()
end

function StateDead:leave(param)
end

return StateDead

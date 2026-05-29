local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local LoginWaitTime = 10
local BroadcastDistance = 20

function Entity:broadcastDungeonPacket(packet, filterDistance)
  local curTime = os.time()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() and player.isPlayer and player.login_time_ and curTime - player.login_time_ > LoginWaitTime then
      local needSend = true
      if filterDistance then
        local myPos = self:getPosition()
        local targetPos = self:getPosition()
        if Lib.getPosDistance(myPos, targetPos) > BroadcastDistance then
          needSend = false
        end
      end
      if needSend then
        player:sendPacket(packet)
      end
    end
  end
end

function EntityServer:syncPlayerData()
  local data = {}
  data.maxHp = self:getMaxHp()
  data.hp = self:getCurHp()
  self:sendPacket({
    pid = "syncPlayerData",
    data = data
  })
end

function EntityServer:getAreaID()
  local reportArea = World.cfg.reportArea
  local pos = self:getPosition()
  for i, v in ipairs(reportArea) do
    if pos.x >= v.x[1] and pos.x <= v.x[2] and pos.y >= v.y[1] and pos.y <= v.y[2] and pos.z >= v.z[1] and pos.z <= v.z[2] then
      return v.id
    end
  end
  return -1
end

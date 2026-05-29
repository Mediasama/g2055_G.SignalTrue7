local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local pitch = 0
GMItem["tps/\233\149\156\229\164\180+1"] = function()
  pitch = pitch + 1
  print("oldPitch+1", pitch)
  Me:changeCameraView(nil, 0, pitch, 1, 1)
end
GMItem["tps/\233\149\156\229\164\180-1"] = function()
  pitch = pitch - 1
  print("oldPitch-1", pitch)
  Me:changeCameraView(nil, 0, pitch - 1, 1, 1)
end
GMItem["tps/\230\137\147\229\141\176\230\136\145\231\154\132\232\167\146\229\186\166"] = function()
  local oldPitch = Me:getRotationPitch()
  local oldYaw = Me:getRotationYaw()
  print("oldPitch,oldYaw=", oldPitch, oldYaw)
end

local function getV3angle(v1, v2)
  local denominator = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
  local len1 = math.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
  local len2 = math.sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z)
  return math.deg(math.acos(denominator / (len1 * len2)))
end

local lastDirection
GMItem["tps/\230\137\147\229\141\176\233\149\156\229\164\180"] = function()
  local curCamera = Camera.getActiveCamera()
  local cameraDirection = curCamera:getDirection()
  if lastDirection then
    local qu = Quaternion.fromVectorRotation(cameraDirection, lastDirection)
    local pitch, yaw, roll = qu:toEulerAngle()
    print("++++++++++++++++", pitch, yaw, roll)
  end
  lastDirection = cameraDirection
end
GMItem["g2055/\229\136\135\230\141\162\229\138\168\228\189\1561"] = function()
  Me:updateUpperAction("g2047_run_gun", -1, false)
end
GMItem["g2055/\229\136\135\230\141\162\229\138\168\228\189\1562"] = function()
  EntityServer.playAction({
    entity = self,
    actionName = anim,
    actionTime = -1,
    includeSelf = true
  })
end
GMItem["g2055/\232\162\171\229\135\187\233\128\1283"] = function(self)
  local diePos = self:getPosition()
  local pos = Lib.v3(diePos.x + 1, diePos.y + 1, diePos.z + 1)
  self:setForceMove(pos, 2)
  self:sendPacket({
    pid = "syncTargetForward",
    pos = pos
  })
end
GMItem["g2055/\232\184\162ATM"] = function(self)
  local skillName = "myplugin/" .. World.cfg.kickATMSkill
  Me:changeState(Define.CHARACTER_STATE_TYPE.SKILL, {skillName = skillName})
end
GMItem["g2055/\231\148\159\230\136\144\231\144\131\228\189\147"] = function(self)
  local parent = World.CurMap:getScene():getRoot()
  local myPos = self:getPosition()
  for i = 1, 12 do
    local x = myPos.x - 1.8 + i * 0.3
    for j = 1, 12 do
      local y = myPos.y + j * 0.3
      for k = 1, 12 do
        local z = myPos.z - 1.8 + k * 0.3
        local newPos = Lib.v3(x, y, z)
        local collider = Instance.Create("CollisionObject")
        local colliderConf = {
          extent = {
            x = 0.15,
            y = 0.15,
            z = 0.15
          },
          type = "Box"
        }
        collider:setShape(colliderConf)
        collider:setCanBlockCamera(false)
        collider:setLocalPosition(newPos)
        collider.bindEffect = true
        collider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
        parent:addChild(collider)
      end
    end
  end
end
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\231\167\187\229\138\1681"] = function(self)
  Blockman.Instance().gameSettings.poleForward = 1
  Blockman.Instance().gameSettings.poleStrafe = 0
end
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\231\167\187\229\138\1682"] = function(self)
  Blockman.Instance().gameSettings.poleForward = -1
  Blockman.Instance().gameSettings.poleStrafe = 0.1
end
local sendIndex = 0
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/10\229\184\167\228\184\128\230\157\161\228\184\150\231\149\140\230\182\136\230\129\175"] = function(self, val)
  if self.gmAutoSendMsgTimer then
    self.gmAutoSendMsgTimer()
    self.gmAutoSendMsgTimer = nil
    sendIndex = 0
    return
  end
  self.gmAutoSendMsgTimer = World.Timer(10, function()
    local ChatHelper = T(World, "ChatHelper")
    sendIndex = sendIndex + 1
    ChatHelper:sendChatMsg(Define.ChatPage.World, {
      fromId = Me.platformUserId,
      msg = sendIndex,
      msgType = Define.MsgType.Text
    })
    return true
  end)
end

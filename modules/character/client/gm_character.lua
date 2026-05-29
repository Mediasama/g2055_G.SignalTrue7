local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\184\154\229\138\161\229\183\165\229\133\183/\230\173\187\228\186\161"] = function()
  local data = {}
  data.who = ""
  data.weaponName = "packet.weaponName"
  Lib.emitEvent(Event.EVENT_UI_OPEN_DEAD, data)
  UI:closeWnd("gm")
end
GMItem["g2055/\231\169\186\229\156\176\229\155\190"] = function()
  local pos = World.cfg.initPos
  local world = World.CurWorld
  world:loadCurMap({
    id = 10000,
    name = "map002",
    objID = Me.objID,
    pos = pos
  }, pos)
  Me:setProp("gravity", 0)
  local CameraManager = T(Lib, "CameraManager")
  CameraManager:freeView()
  local show_collision = true
  local debugDraw = DebugDraw.instance
  if show_collision and not debugDraw:isEnabled() then
    debugDraw:setEnabled(show_collision)
  end
  debugDraw:setDrawColliderEnabled(show_collision)
  debugDraw:setDrawAuraEnabled(show_collision)
  debugDraw:setDrawRegionEnabled(show_collision)
end
GMItem["g2055/\230\183\187\229\138\160hitbox"] = function()
  local HitBoxHelper = T(Lib, "HitBoxHelper")
  HitBoxHelper:addPlayerHitBox(Me)
end
GMItem["g2055/\231\167\187\233\153\164hitbox"] = function()
  local HitBoxHelper = T(Lib, "HitBoxHelper")
  HitBoxHelper:removePlayerHitBox(Me)
end
GMItem["g2055/\230\183\187\229\138\160\232\135\170\229\138\168\229\188\128\231\129\171\230\161\134"] = function()
  local AimHelper = T(Lib, "AimHelper")
  AimHelper:addPlayerAutoFireBox(Me)
end
GMItem["g2055/\231\167\187\233\153\164\232\135\170\229\138\168\229\188\128\231\129\171\230\161\134"] = function()
  local AimHelper = T(Lib, "AimHelper")
  AimHelper:removeAutoFireBox(Me)
end
GMItem["g2055/\230\183\187\229\138\160\232\135\170\231\158\132\230\161\134"] = function()
  local AimHelper = T(Lib, "AimHelper")
  AimHelper:addPlayerAutoAimBox(Me)
end
GMItem["g2055/\231\167\187\233\153\164\232\135\170\231\158\132\230\161\134"] = function()
  local AimHelper = T(Lib, "AimHelper")
  AimHelper:removeAutoAimBox(Me)
end

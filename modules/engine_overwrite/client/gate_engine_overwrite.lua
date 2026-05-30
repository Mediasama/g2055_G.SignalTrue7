local main = {}
local tickEngineHandler = L("tickEngineHandler", handle_tick)

function handle_tick(frameTime)
  tickEngineHandler(frameTime)
end

function main:init()
  self:initLog()
  self:setGlobalProperty()
  CGame.instance:toggleDebugMessageShown(false)
  self:initGlobalEvent()
end

function main:setGlobalProperty()
  GlobalProperty.Instance():setBoolProperty("DebugSound", false)
  GlobalProperty.Instance():setBoolProperty("DisableCheckBlockTouch", true)
end

function main:initLog()
  Lib.setDebugLog(CGame.Instance():isDebuging())
end

function main:initGlobalEvent()
  Lib.subscribeKeyDownEvent("key.pull", function()
    local pos = Me:getPosition()
    local str = string.format("%.2f,%.2f,%.2f,%.2f", pos.x, pos.y, pos.z, Blockman.instance:viewerRenderYaw())
    PlatformUtil.copyToClipboard(str, string.len(str))
    print("PlatformUtil.copyToClipboard " .. str)
  end)

  Lib.subscribeKeyDownEvent("key.k", function()
    Me.isFly = not Me.isFly
    if Me.isFly then
        Me:setProp("gravity", 0)
        -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "FLY ON (K)")
    else
        Me:setProp("gravity", 0.08)
        -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "FLY OFF (K)")
    end
  end)

  Lib.subscribeKeyDownEvent("key.u", function()
    if Me.isFly then
        local pos = Me:getPosition()
        pos.y = pos.y + 2
        Me:setPosition(pos)
    end
  end)

  Lib.subscribeKeyDownEvent("key.j", function()
    if Me.isFly then
        local pos = Me:getPosition()
        pos.y = pos.y - 2
        Me:setPosition(pos)
    end
  end)

  Lib.subscribeKeyDownEvent("key.h", function()
    -- Rapid Money / ATM exploit
    local myPos = Me:getPosition()
    local nearestATM
    local minDist = 10
    for _, entity in pairs(World.CurWorld:getAllEntity()) do
        local dist = Lib.getPosDistance(myPos, entity:getPosition())
        if dist < minDist then
            if entity:cfg().isATM or entity:cfg().itemID == 901001 then
                nearestATM = entity
                minDist = dist
            end
        end
    end

    if nearestATM then
        if nearestATM:cfg().itemID == 901001 then
            -- Spam pick gold item
            for i = 1, 10 do
                Me:sendPacket({
                    pid = "pickItemFromClient",
                    objID = nearestATM.objID,
                    index = 1
                })
            end
            -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "SPAMMING PICKUP")
        else
            -- Spam hit ATM
            local info = {
                hurtObjID = nearestATM.objID,
                attackObjID = Me.objID,
                hurtType = 6, -- ATM
                damagePos = nearestATM:getPosition(),
                sourcePos = Me:getPosition(),
                targetPos = nearestATM:getPosition(),
                attackCount = 1,
                weaponId = 101000
            }
            for i = 1, 20 do
                Me:sendPacket({
                    pid = "BulletDoDamage",
                    damageInfo = info
                })
            end
            -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "SPAMMING ATM")
        end
    else
        -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "NO ATM/GOLD NEARBY")
    end
  end)

  Lib.subscribeKeyDownEvent("key.x", function()
    -- Kill Nearest Player (Immortal Killer)
    local myPos = Me:getPosition()
    local target
    local minDist = 50
    for _, entity in pairs(World.CurWorld:getAllEntity()) do
        if entity.isPlayer and entity.objID ~= Me.objID then
            local dist = Lib.getPosDistance(myPos, entity:getPosition())
            if dist < minDist then
                target = entity
                minDist = dist
            end
        end
    end

    if target then
        local info = {
            hurtObjID = target.objID,
            attackObjID = Me.objID,
            hurtType = 2, -- BODY
            damagePos = target:getPosition(),
            sourcePos = Me:getPosition(),
            targetPos = target:getPosition(),
            attackCount = 1,
            weaponId = 102004 -- Minigun
        }
        -- Send massive damage
        Me:sendPacket({
            pid = "BulletDoDamage",
            damageInfo = info,
            skillJsonConf = { damage = 9999 }
        })
        -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "KILLING: " .. target:getName())
    else
        -- Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "NO TARGET FOUND")
    end
  end)

  -- Integrated Mod Loop (Auto-Loot, ATM, KillAura, Vault)
  World.Timer(5, function()
      if not Me or not Me:isValid() then return true end
      local myPos = Me:getPosition()

      -- 1. Auto-Loot MONEY ONLY (Distance: 200m)
      for _, obj in pairs(World.CurWorld:getAllObject()) do
          if obj.className == "DropItemClient" then
              local cfg = obj.cfg and obj:cfg()
              if cfg and cfg.itemID == 901001 then -- Money only
                  local dist = Lib.getPosDistance(myPos, obj:getPosition())
                  if dist < 200 then
                      Me:sendPacket({ pid = "pickItemFromClient", objID = obj.objID, index = 1 })
                  end
              end
          end
      end

      -- 2. ATM / Car Remote Kicker (50 Hits/tick for instant destruction)
      for _, obj in pairs(World.CurWorld:getAllObject()) do
          local cfg = obj.cfg and obj:cfg()
          if cfg and (cfg.isATM or cfg.isTrolley) then
              local dist = Lib.getPosDistance(myPos, obj:getPosition())
              if dist < 200 then
                  local info = {
                      hurtObjID = obj.objID,
                      attackObjID = Me.objID,
                      hurtType = cfg.isATM and 6 or 2,
                      damagePos = obj:getPosition(),
                      sourcePos = myPos,
                      targetPos = obj:getPosition(),
                      attackCount = 50, -- Rapid Hits
                      weaponId = 101000
                  }
                  Me:sendPacket({ pid = "BulletDoDamage", damageInfo = info, skillJsonConf = { damage = 99999 } })
              end
          end
      end

      -- 3. Optimized KillAura (30m, 10 Hits) - Toggle with 'X'
      if Me.enableKillAura then
          for _, entity in pairs(World.CurWorld:getAllEntity()) do
              if entity.isPlayer and entity.objID ~= Me.objID and not entity:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) then
                  local dist = Lib.getPosDistance(myPos, entity:getPosition())
                  if dist < 30 then
                      local info = {
                          hurtObjID = entity.objID,
                          attackObjID = Me.objID,
                          hurtType = 2,
                          damagePos = entity:getPosition(),
                          sourcePos = myPos,
                          targetPos = entity:getPosition(),
                          attackCount = 10,
                          weaponId = 101000
                      }
                      Me:sendPacket({ pid = "BulletDoDamage", damageInfo = info, skillJsonConf = { damage = 99999 } })
                  end
              end
          end
      end

      -- 4. Global Vault/Gang Stealer
      for _, entity in pairs(World.CurWorld:getAllEntity()) do
          if entity.isPlayer and entity.objID ~= Me.objID then
              local dist = Lib.getPosDistance(myPos, entity:getPosition())
              if dist < 100 then
                  -- Remote Steal from Vault
                  Me:sendPacket({
                      pid = "operateFacility",
                      params = {
                          ownerId = entity.platformUserId,
                          manner = 4, -- Steal
                          type = 3, -- Vault
                          requestData = { delta = 1000000 }
                      }
                  })
              end
          end
      end
      Me:sendPacket({ pid = "getTerritoryAward" })
      if not Me:getGangId() then
          Me:sendPacket({ pid = "createNewGang", name = "MOD_USER_" .. Me.objID, logoId = 1 })
      end

      return true
  end)

  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_PAUSE", Event.EVENT_GAME_PAUSE, function()
    if Me.stopGameBgm then
      Player.CurPlayer:stopGameBgm()
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_RESUME", Event.EVENT_GAME_RESUME, function()
    if Me.playGameBgm then
      Player.CurPlayer:playGameBgm()
    end
  end)
end

main:init()

local CameraManager = T(Lib, "CameraManager")
local AbilityManager = T(Lib, "AbilityManager")
local setting = require("common.setting")

function AbilityManager:init(entity)
  self.entity = entity
  self:AddAutoAimAbility()
  World.LightTimer("initAction", 2, function()
    if self.entity.weapon then
      self.entity.weapon:initAction()
    end
  end)
  print("World.cfg.cameraSensitive", World.cfg.cameraSensitive)
  Blockman.instance.gameSettings:setCameraSensitive(World.cfg.cameraSensitive or 2)
end

function AbilityManager:AddAutoAimAbility()
  local AutoAim = T(Lib, "AutoAim")
  AutoAim:init(self.entity)
end

function AbilityManager:useFistAbility(cameraCfg)
  self.isWeaponView = false
  CameraManager:freeView(cameraCfg)
end

function AbilityManager:useGunAbility(cameraCfg)
  self.isWeaponView = true
  CameraManager:weaponView(cameraCfg)
end

function AbilityManager:useDriveAbility()
  self.isWeaponView = false
  CameraManager:freeView()
  Me:sendPacket({
    pid = "changeWeapon2s",
    weaponId = tonumber(World.cfg.defaultWeaponID)
  })
end

return AbilityManager

local GangIconConfig = T(Config, "GangIconConfig")
local WinBastionDoorPlate = M

function WinBastionDoorPlate:initUI()
  self.imgIcon = self:child("ImageGangIcon")
  self.txtGangName = self:child("TextGangName")
  self.txtName = self:child("TextName")
  self.txtNameNoGang = self:child("TextNameNoGang")
end

function WinBastionDoorPlate:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REFRESH_PLAYER_GANG_ICON, function()
    self:updateView()
  end)
end

function WinBastionDoorPlate:initView(param)
  self.info = param
  self:updateView()
end

function WinBastionDoorPlate:updateView(objID, data)
  if not self.isValid then
    return
  end
  if not self.info then
    return
  end
  local ownerId = self.info.ownerId or 0
  local owner = Game.GetPlayerByUserId(ownerId)
  if owner then
    local houseName = Lang:toText({
      "bastion.doorplate.word",
      owner.name
    })
    self.txtName:setText(houseName)
    local player = World.CurWorld:getObject(owner.objID)
    if player and player:isValid() and player.isPlayer then
      local gangData = player:getValue("gangIconInfo")
      if gangData then
        local imgPath = GangIconConfig:getGangButtonIcon(gangData.id)
        if imgPath then
          self.imgIcon:setImage(imgPath)
          self.imgIcon:setVisible(true)
        end
        self.txtGangName:setText(gangData.name)
        self.txtNameNoGang:setText("")
        self.txtName:setText(houseName)
      else
        self.imgIcon:setVisible(false)
        self.txtGangName:setText("")
        self.txtNameNoGang:setText(houseName)
        self.txtName:setText("")
      end
    else
      self.imgIcon:setVisible(false)
      self.txtGangName:setText("")
    end
  else
    self.txtNameNoGang:setText("")
    self.txtName:setText("")
    self.txtGangName:setText("")
    self.imgIcon:setVisible(false)
  end
end

function WinBastionDoorPlate:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionDoorPlate:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinBastionDoorPlate

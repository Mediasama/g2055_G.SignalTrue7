function M:init()
  self.imageIcon = self:child("ImageIcon")
  
  self.textOccupyName = self:child("TextOccupyName")
end

function M:onOpen()
  self:init()
end

function M:initIcon()
  self.textOccupyName:setText("")
end

function M:onDataChange(data)
  if data.name == nil then
    self.textOccupyName:setText(Lang:toText("territory.ui.tips.unOccupied"))
  else
    self.textOccupyName:setText(data.name)
    local owner = data.owner
    local ownerType = data.ownerType
    local isMyOccupy = false
    if ownerType == Define.TerritoryOwnerType.Player then
      if owner == Me.platformUserId then
        isMyOccupy = true
      end
    elseif Me:getGangId() == owner then
      isMyOccupy = true
    end
  end
end

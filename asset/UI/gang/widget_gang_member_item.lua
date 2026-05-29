function M:init()
  self.textMemberPosition = self:child("TextMemberPosition")
  
  self.textMemberName = self:child("TextMemberName")
  self.color = {
    [Define.GangsPosition.ChairMan] = Color3.new(0.5568627450980392, 0.9019607843137255, 0.23137254901960785),
    [Define.GangsPosition.Member] = Color3.new(1, 1, 1)
  }
  self.mySelfColor = Color3.new(0.996078431372549, 0.4235294117647059, 0.1411764705882353)
end

function M:onDataChanged(data)
  data = data.data
  self.textMemberPosition:setText(Lang:toText(Define.GangsPositionName[data.position]))
  self.textMemberName:setText(data.name)
  if data.userId == Me.platformUserId then
    self.textMemberPosition:setTextColours(self.mySelfColor)
    self.textMemberName:setTextColours(self.mySelfColor)
  else
    self.textMemberPosition:setTextColours(self.color[data.position])
    self.textMemberName:setTextColours(self.color[data.position])
  end
end

function M:destroy()
end

M:init()

function M:init()
  self.textPlayerName = self:child("TextPlayerName")
  
  self.buttonDeny = self:child("ButtonDeny")
  self.buttonAccept = self:child("ButtonAccept")
  
  function self.buttonDeny.onMouseClick()
    Me:processApplications(self.userId, Define.ProcessApplication.Deny)
  end
  
  function self.buttonAccept.onMouseClick()
    Me:processApplications(self.userId, Define.ProcessApplication.Access)
  end
end

function M:onDataChanged(data)
  self.index = data.index
  self.data = data.data
  self.textPlayerName:setText(self.data.name)
  self.userId = self.data.userId
end

function M:destroy()
end

M:init()

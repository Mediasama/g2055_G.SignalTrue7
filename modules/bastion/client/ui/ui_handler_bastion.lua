local guiMgr = L("guiMgr", GUIManager:Instance())
if not guiMgr:isEnabled() then
  print("useNewUI: false")
  return
end

function UI:getSceneWindow(name)
  return guiMgr:getSceneWindow(name)
end

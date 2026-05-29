local MapClient = T(World, "MapClient")
local loadCurMap = MapClient.loadCurMap

function MapClient:loadCurMap(data, pos, mapChunkData)
  loadCurMap(self, data, pos, mapChunkData)
  print("MapClient:loadCurMapMapClient:loadCurMapMapClient:loadCurMap")
end

local m_TattooManager = require("server.tattoo_manager")
local handles = T(Player, "PackageHandlers")

function handles:onRequestTattoo(packet)
  if self:isPlayerInDieState() then
    return {
      code = Define.TattooPacketCode.ErrorRequest
    }
  end
  return {
    code = m_TattooManager:getInstance():requestTattoo(self, packet.objID, packet.tattooId)
  }
end

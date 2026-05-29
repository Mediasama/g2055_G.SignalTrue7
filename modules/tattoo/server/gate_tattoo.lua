local TattooServer = T(Lib, "TattooServer")
local m_TattooManager = require("server.tattoo_manager")

function TattooServer:export_interruptTattoo(player)
  m_TattooManager:getInstance():interruptTattoo(player)
end

return TattooServer

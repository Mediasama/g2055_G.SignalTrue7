require("common.gm")
if PlatformUtil.isPlatformWindows() then
  LogUtil.setMaxMessageSize(102400)
end
require("script_common.packet_convert")
if World.isClient then
  require("script_client.main")
else
  require("script_server.main")
end

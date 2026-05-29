local BastionUtils = require("common.bastion_utils")
local BastionServer = T(Lib, "BastionServer")

function BastionServer:export_getNSamples(samples, amount, putBack, repeatIfNotEnough)
  return BastionUtils.Instance():getNSamples(samples, amount, putBack, repeatIfNotEnough)
end

return BastionServer

local GoodsShelfUtils = require("common.goods_shelf_utils")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")

function GoodsShelfClient:export_getGoodsConfig(type, id)
  return GoodsShelfUtils.Instance():getGoodsConfig(type, id)
end

return GoodsShelfClient

local GoodsBaseConfig = T(Config, "GoodsBaseConfig")
local goodsBase = {}

function GoodsBaseConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/goods_base.csv", 2)
  for _, v in pairs(config) do
    local data = {
      id = tonumber(v.goods_id),
      name = v.goods_name or "",
      desc = v.goods_tips or "",
      firstType = tonumber(v.first_type),
      secondType = tonumber(v.second_type),
      modelPath = v.model_path,
      iconPath = v.icon_path or "",
      maxNum = tonumber(v.max_own),
      stackNum = tonumber(v.stack_num),
      ifDieDrop = tonumber(v.if_die_drop) == 1,
      ifPicActor = tonumber(v.if_pic_actor),
      detailPic = v.detail_pic,
      detailActor = v.detail_actor,
      detailSkinData = self:parseSkinData(v.s_skin_data or ""),
      detailActorAnim = v.detail_actor_anim,
      detailActorScale = tonumber(v.detail_actor_scale),
      detailActorRotateY = tonumber(v.detail_actor_rotateY)
    }
    goodsBase[data.id] = data
  end
end

function GoodsBaseConfig:getCfgById(id)
  local cfg = goodsBase[id]
  if not cfg then
    Lib.logError("can not find GoodsBaseConfig, id:", id)
    return
  end
  return cfg
end

function GoodsBaseConfig:getItemType(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.firstType
  end
end

function GoodsBaseConfig:isCostItem(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.firstType == 8 or cfg.firstType == 9
  end
end

function GoodsBaseConfig:parseSkinData(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "=")
  local data = {}
  if samplesStr[1] and samplesStr[2] then
    data[samplesStr[1]] = samplesStr[2] or ""
  end
  return data
end

GoodsBaseConfig:init()
return GoodsBaseConfig

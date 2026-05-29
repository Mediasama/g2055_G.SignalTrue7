Define.TattooPacketCode = {
  Success = 1,
  OtherPlayerTattooing = 2,
  ErrorRequest = 3,
  ExistTattoo = 4,
  Empty = 5,
  NoEnoughMoney = 6
}
Define.TattooPacketTips = {
  [Define.TattooPacketCode.OtherPlayerTattooing] = "tattoo.tips.other.player.tattoo",
  [Define.TattooPacketCode.ErrorRequest] = "tattoo.tips.error.request",
  [Define.TattooPacketCode.Empty] = "tattoo.tips.empty.tattoo",
  [Define.TattooPacketCode.ExistTattoo] = "tattoo.tips.exist.tattoo",
  [Define.TattooPacketCode.NoEnoughMoney] = "tips.no.money"
}

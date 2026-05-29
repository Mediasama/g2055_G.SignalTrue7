local self = AsyncProcess
local strfmt = string.format

function AsyncProcess.GetVoiceInfo(userId)
  local url = strfmt("%s/gameaide/api/v1/user/voice/profit", self.ServerHttpHost)
  self.HttpRequest("GET", url, {
    {"userId", userId}
  }, function(response, isSuccess)
    if not isSuccess then
      print("GetVoiceInfo Error: ", response.code)
      return
    end
    local player = Game.GetPlayerByUserId(userId)
    if player then
      player:initVoiceInfo(response.data)
    end
  end, {}, true)
end

function AsyncProcess.SetVoiceInfo(player)
  local url = strfmt("%s/gameaide/api/v1/user/voice/profit/update", self.ServerHttpHost)
  local params = {
    {
      "userId",
      player.platformUserId
    }
  }
  local body = {
    userId = player.platformUserId,
    expireDateLong = player:getSoundMoonCardMac(),
    freeTimes = player:getFreeSoundTimes(),
    times = player:getSoundTimes()
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("SetVoiceInfo Error: ", response.code)
      return
    end
    print("SetVoiceInfo succ:", Lib.v2s(response, 3))
  end, body, true)
end

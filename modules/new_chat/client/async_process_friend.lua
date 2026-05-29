local self = AsyncProcess
local strfmt = string.format
local cjson = require("cjson")

function AsyncProcess.GetPlayerOnlineState(userIds, callback)
  local url = strfmt("%s/gameaide/api/v1/game/friends/status", self.ClientHttpHost)
  local params = {}
  local body = userIds
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AsyncProcess GetPlayerOnlineState Error: ", response.code)
      return
    end
    callback(response.data)
  end, body, true)
end

function AsyncProcess.ClientGetChatFriendWithGameId(language, type, pageNo, pageSize, callback)
  local url = strfmt("%s/gameaide/api/v1/game/friends", self.ClientHttpHost)
  local params = {
    {
      "gameId",
      World.GameName
    },
    {
      "language",
      tostring(language)
    },
    {
      "pageNo",
      tostring(pageNo)
    },
    {
      "pageSize",
      tostring(pageSize)
    },
    {"type", type}
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("ClientGetChatFriendWithGameId Error: ", response.code)
      return
    end
    callback(response.data)
  end, {}, true)
end

function AsyncProcess.CheckClientPlayerIsMyFriend(userId, callback)
  local url = strfmt("%s/gameaide/api/v1/game/friend/judge", self.ClientHttpHost)
  local params = {
    {
      "gameId",
      World.GameName
    },
    {
      "judgeUserId",
      userId
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("CheckClientPlayerIsMyFriend Error: ", response.code)
      return
    end
    if callback then
      callback(response.data)
    end
  end, {}, true)
end

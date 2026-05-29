local Player = _ENV.Player
local handles = T(Player, "PackageHandlers")
local PlayerSpInfoManager = T(Lib, "PlayerSpInfoManager")

function Player:loginRequestFriendInfo()
  self:initServerFriendUserIdList()
end

function Player:initServerFriendUserIdList()
  if not self:isValid() then
    return
  end
  self.existFriendList = {}
  self.requestCounter = 0
  self:requestWebFriendUserIdList(Define.chatFriendType.platform)
  self:requestWebFriendUserIdList(Define.chatFriendType.game)
end

function Player:requestWebFriendUserIdList(type)
  AsyncProcess.GetChatFriendUserIdWithGameId(self.platformUserId, type, function(data)
    local userIdList = {}
    for _, userId in pairs(data) do
      if Define.chatFriendType.game == type then
        self.existFriendList[userId] = Define.friendStatus.gameFriend
      elseif Define.chatFriendType.platform == type then
        self.existFriendList[userId] = Define.friendStatus.platformFriend
      end
      table.insert(userIdList, {userId = userId})
    end
    self.requestCounter = self.requestCounter + 1
    if self.requestCounter == 2 then
      self:pushClientExistFriendList()
    end
  end)
end

function Player:getPlayerFriendsNum(friendType)
  if not self.existFriendList then
    return 0
  end
  local totalNum = 0
  for _, type in pairs(self.existFriendList) do
    if friendType == type then
      totalNum = totalNum + 1
    end
  end
  return totalNum
end

function Player:removePlayerFriendFromExist(userId)
  if not self.existFriendList then
    self.existFriendList = {}
  end
  self.existFriendList[userId] = nil
end

function Player:addPlayerFriendFromExist(userId, status)
  if not self.existFriendList then
    self.existFriendList = {}
  end
  self.existFriendList[userId] = status or Define.friendStatus.gameFriend
end

function Player:checkPlayerIsMyFriend(userId)
  if not self.existFriendList then
    self.existFriendList = {}
  end
  if self.existFriendList[userId] then
    return self.existFriendList[userId]
  end
  return Define.friendStatus.notFriend
end

function Player:pushClientExistFriendList()
  self:sendPacket({
    pid = "PushClientExistFriendList",
    existFriendList = self.existFriendList
  })
end

function handles:UpdateServerExistFriendList(packet)
  if self.existFriendList and self.existFriendList[packet.userId] ~= packet.status then
    self.existFriendList[packet.userId] = packet.status
  end
end

function Player:initServerFriendDataList()
  self.allFriendData = {}
  self.allFriendData[Define.chatFriendType.game] = {}
  self.allFriendData[Define.chatFriendType.platform] = {}
  self.allFriendData[Define.chatFriendType.game].nearTimeList = {}
  self.allFriendData[Define.chatFriendType.platform].nearTimeList = {}
  local player = Game.GetPlayerByUserId(self.platformUserId)
  local language = "en_US"
  if player then
    local userCache = UserInfoCache.GetCache(self.platformUserId)
    language = userCache and userCache.language or "en_US"
  end
  self.allFriendData.language = language
  self:updateFriendDataList()
end

function Player:updateFriendDataList()
  self.allFriendData[Define.chatFriendType.game].dataList = {}
  self.allFriendData[Define.chatFriendType.platform].dataList = {}
  self.allFriendData[Define.chatFriendType.platform].getFriendIsEnd = false
  self.allFriendData[Define.chatFriendType.game].getFriendIsEnd = false
  self:requestFriendInfoPage(Define.chatFriendType.platform, 0, Define.friendOnceRequestNum)
  self:requestFriendInfoPage(Define.chatFriendType.game, 0, Define.friendOnceRequestNum)
end

function Player:requestFriendInfoPage(type, pageNo, pageSize)
  if not self:isValid() then
    return
  end
  AsyncProcess.GetChatFriendWithGameId(self.platformUserId, self.allFriendData.language, type, pageNo, pageSize, function(data)
    self.allFriendData[type].totalPage = data.totalPage
    self.allFriendData[type].totalSize = data.totalSize
    for _, val in pairs(data.data) do
      table.insert(self.allFriendData[type].dataList, val)
    end
    if pageNo < data.totalPage - 1 then
      self.allFriendData[type].getFriendIsEnd = false
      self:requestFriendInfoPage(type, pageNo + 1, pageSize)
    else
      self.allFriendData[type].getFriendIsEnd = true
      self:dealAsyncFriendInfo(type)
    end
    if Define.chatFriendType.game == type then
      self:updateConditionAutoCounts(Define.tagConditionType.friend, data.totalSize)
    end
  end)
end

function Player:dealAsyncFriendInfo(type)
  if not self.allFriendData[type].getFriendIsEnd then
    return
  end
  self.allFriendData[type].nearTimeList = {}
  for key, val in pairs(self.allFriendData[type].dataList) do
    table.insert(self.allFriendData[type].nearTimeList, val)
  end
end

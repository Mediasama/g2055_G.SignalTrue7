local Player = _ENV.Player
local handles = T(Player, "PackageHandlers")
local chatSetting = World.cfg.chatSetting or {}
local operationType = FriendManager.operationType

function Player:initClientFriendInfo()
  if self.allFriendData then
    return
  end
  if not self.existFriendList then
    self.existFriendList = {}
  end
  self.allFriendData = {}
  self.allFriendData[Define.chatFriendType.game] = {}
  self.allFriendData[Define.chatFriendType.game].dataList = {}
  self.allFriendData[Define.chatFriendType.platform] = {}
  self.allFriendData[Define.chatFriendType.platform].dataList = {}
  local player = Game.GetPlayerByUserId(Me.platformUserId)
  local language = "en_US"
  if player then
    local userCache = UserInfoCache.GetCache(Me.platformUserId)
    language = userCache and userCache.language or "en_US"
  end
  self.allFriendData.language = language
end

function Player:doRequestServerFriendInfo(friendType, pageNum)
  if not self.allFriendData then
    self:initClientFriendInfo()
  end
  local requestType = friendType or Define.chatFriendType.game
  local requestPage = 0
  if pageNum then
    requestPage = pageNum
  elseif self.allFriendData[requestType] and self.allFriendData[requestType].pageNo then
    requestPage = self.allFriendData[requestType].pageNo
  end
  self:requestWebFriendInfo(requestType, requestPage)
end

function Player:requestWebFriendInfo(type, requestPage)
  local pageSize = Define.friendOnceRequestNum
  local pageNo = requestPage
  if pageNo < 0 then
    pageNo = 0
  end
  AsyncProcess.ClientGetChatFriendWithGameId(self.allFriendData.language, type, pageNo, pageSize, function(data)
    self.allFriendData[type].totalPage = data.totalPage
    self.allFriendData[type].totalSize = data.totalSize
    self.allFriendData[type].pageNo = data.pageNo
    self.allFriendData[type].dataList = {}
    for _, val in pairs(data.data) do
      table.insert(self.allFriendData[type].dataList, val)
      if type == Define.chatFriendType.game then
        Me:addPlayerFriendFromExist(val.userId, Define.friendStatus.gameFriend)
      else
        Me:addPlayerFriendFromExist(val.userId, Define.friendStatus.platformFriend)
      end
    end
    table.sort(self.allFriendData[type].dataList, function(a, b)
      return a.status < b.status
    end)
    Lib.emitEvent(Event.EVENT_UPDATE_FRIEND_LIST_SHOW, type)
    if #self.allFriendData[type].dataList <= 0 then
      return
    end
  end)
end

function Player:friendOperactionNotice(targetUserId, opType)
  if opType == operationType.AGREE then
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Player:friendOperactionNotice  AGREE", targetUserId, opType)
    Me:doRequestServerFriendInfo(Define.chatFriendType.game)
    Me:doRequestServerFriendInfo(Define.chatFriendType.platform)
    Me:addPlayerFriendFromExist(targetUserId, Define.friendStatus.gameFriend)
  elseif opType == operationType.DELETE then
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Player:friendOperactionNotice   DELETE ", targetUserId, opType)
    Me:doRequestServerFriendInfo(Define.chatFriendType.game)
    Me:doRequestServerFriendInfo(Define.chatFriendType.platform)
    Me:removePlayerFriendFromExist(targetUserId)
  end
  self:sendPacket({
    pid = "FriendOperactionNotice",
    targetUserId = targetUserId,
    operationType = opType
  })
end

function Player:removePlayerFriendFromExist(userId)
  if not self.existFriendList then
    self.existFriendList = {}
  end
  self.existFriendList[userId] = nil
  self:updateServerExistFriendList(userId, Define.friendStatus.notFriend)
end

function Player:addPlayerFriendFromExist(userId, status)
  if not self.existFriendList then
    self.existFriendList = {}
  end
  if self.existFriendList[userId] ~= status then
    self.existFriendList[userId] = status or Define.friendStatus.gameFriend
    self:updateServerExistFriendList(userId, status)
  end
end

function Player:checkPlayerIsMyFriend(userId)
  if not self.allFriendData then
    self:initClientFriendInfo()
  end
  if not self.existFriendList then
    self.existFriendList = {}
  end
  if self.existFriendList[userId] then
    return self.existFriendList[userId]
  end
  for key, val in pairs(self.allFriendData[Define.chatFriendType.game].dataList) do
    if tonumber(userId) == tonumber(val.userId) then
      self.existFriendList[userId] = Define.friendStatus.gameFriend
      return self.existFriendList[userId]
    end
  end
  for key, val in pairs(self.allFriendData[Define.chatFriendType.platform].dataList) do
    if tonumber(userId) == tonumber(val.userId) then
      self.existFriendList[userId] = Define.friendStatus.platformFriend
      return self.existFriendList[userId]
    end
  end
  return Define.friendStatus.notFriend
end

function handles:PushClientExistFriendList(packet)
  if not self.existFriendList then
    self.existFriendList = {}
  end
  for userId, val in pairs(packet.existFriendList) do
    self.existFriendList[userId] = val
  end
end

function Player:updateServerExistFriendList(userId, status)
  Me:sendPacket({
    pid = "UpdateServerExistFriendList",
    userId = userId,
    status = status
  })
end

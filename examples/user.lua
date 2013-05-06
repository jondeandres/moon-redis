local Model
do
  local _table_0 = require("moon-redis.model")
  Model = _table_0.Model
end
local redis = require('redis')
local client = redis.connect('127.0.0.1', 6379)
Model.client = client
do
  local _parent_0 = Model
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, ...)
      if _parent_0 then
        return _parent_0.__init(self, ...)
      end
    end,
    __base = _base_0,
    __name = "User",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.attrs = {
    'name'
  }
  self.model = "users"
  self.counters = {
    'tweets'
  }
  self.collections = {
    followers = function()
      return User
    end
  }
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  User = _class_0
end
local user1 = User()
user1.name = 'Bob'
user1:save()
local user2 = User({
  name = 'Alice'
})
user2:save()
local user3 = User:create({
  name = 'Trudy'
})
user1:incr_tweets()
user1:incr_tweets()
user1:incr_tweets()
print(user1:tweets_count())
user1:decr_tweets()
print(user1:tweets_count())
user1:add_followers(user2.id)
user1:add_followers(user3.id)
print(#user1:followers())
user1:remove_followers(user2.id)
return print(#user1:followers())

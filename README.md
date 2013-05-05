# moon-redis

Library written in MoonScript, <http://moonscript.org>. You can create your own objects mapped to Redis structures.

## Usage

```moonscript
export User
class User extends RedisModel
  @model: "users"
  @attrs: { 'name' }
  @counters: { 'tweets' }
  @collections: { followers: -> User }

user1 = User!
user1.name = 'Bob'
user1\save!

user2 = User({name: 'Alice'})
user2\save!

user3 = User\create({name: 'Trudy'})

user1\incr_tweets!
user1\incr_tweets!
user1\incr_tweets!
print user1\tweets_count! -- 3

user1\decr_tweets!
print user1\tweets_count! -- 2

user1\add_followers(user2.id)
user1\add_followers(user3.id)
print #user1\followers! -- 2

user1\remove_followers(user2.id)
print #user1\followers! -- 1
```

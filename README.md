# moon-redis

Library written in MoonScript, <http://moonscript.org>. You can create your own objects mapped to Redis structures.

## Installation

moon-redis module is placed in [MoonRocks](http://rocks.moonscript.org). Once you have added MoonRocks to your LuaRocks config.lua you can install it:

```shell
luarocks install moon-redis
```

## Usage
Import `Model` from `moon-redis`:

```moonscript
import Model from require "moon-redis.model"
```

You can configure the Redis client to use:
```moonscript
redis = require('redis')
client = redis.connect('127.0.0.1', 6379)
Model.client = client
```

First, declare your models extending from `Model`:
```moonscript
class User extends Model
  @model: "users"
```

The `@model` value referers to the name to use for the generated keys, ex: `users:id:100`. You can change the primary key changing `@primary_key` value:

```moonscript
export User
class User extends Model
  @primary_key: "identifier"
```

### Attributes
You can define some basic attributes that will be saved as a hash value for each object key.

```moonscript
class User extends Model
  @attrs: { 'name' }

user = User!
user.name = 'Bob'
user\save!
```

### Counters
It's possible to define some counters for your Redis model objects using the `@counters` table.

```moonscript
class User extends Model
  @attrs: { 'name' }
  @model: "users"
  @counters: { 'tweets' }
```

Then you can increment or decrement the value of the objects' counters and get the value:

```moonscript
user\incr_tweets!
user\decr_tweets!
user\incr_tweets!
print user\tweets_count! -- 1
```

### Collections
Sometimes you will need to add collections to your models, you can do it in this way:

```moonscript
class User extends Model
  @attrs: { 'name' }
  @model: "users"
  @collections: { followers: -> User }
```

In this example the `followers` collection that stores User ids. You can add a member to the collection using `add_{name_of_the_collection}`:

```moonscript
user1.add_followers(user2.id)
```

Get the whole collection:
```moonscript
followers = user1.followers
```

Or remove a member from the collection:
```moonscript
user1\remove_followers(user2.id)
```

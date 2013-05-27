class Model
  @primary_key: "id"
  @model: nil
  @counters: {}
  @client: nil
  @collections: {}

-- class methods
  @counter: =>
    @client\get(@counter_key!)

  @increment_counter: =>
    @client\incrby(@counter_key!, 1)

  @relation_class_for: (type, relation) =>
    @[type][relation]!

  @counter_key: =>
    @_counter_key = @_counter_key or @model .. ":count"
    @_counter_key

  @object_key: (id) =>
    @model .. ":" .. @primary_key .. ":" .. id

  @get: (id) =>
    tbl = @client\hgetall(@\object_key(id))
    tbl.id = id
    @(tbl)
  @create: (attributes) =>
    item = @(attributes)
    item\save!
    item

-- instance methods
  new: (attributes) =>
    @spawn_methods!

    if attributes
      for attr, value in pairs attributes
        @[attr] = value

  counter_key_for: (counter) =>
    @\key! .. ':' .. counter

  get_counter: (counter) =>
    value = @@client\get(@\counter_key_for(counter))
    value or 0

  inc_counter: (counter) =>
    @@client\incrby(@\counter_key_for(counter), 1)

  decr_counter: (counter) =>
    @@client\decrby(@\counter_key_for(counter), 1)

  field_key: (field) =>
    @\key! .. ":" .. field

  collection: (name) =>
    collection = {}
    collection_ids = @@client\smembers(@\field_key(name))
    relation_class = @@\relation_class_for('collections', name)

    for id in *collection_ids
      item = relation_class\get(id)
      table.insert(collection, item)
    collection

  add_to_collection: (collection, id) =>
    @@client\sadd(@\field_key(collection), id)

  remove_from_collection: (collection, id) =>
    @@client\srem(@\field_key(collection), id)

  spawn_methods: =>
    __index = getmetatable(@).__index

    -- spawn counter methods
    for counter in *@@counters
      -- count
      name = counter .. '_count'
      __index[name] = ->
        @\get_counter counter

      -- inc
      name = 'incr_' .. counter
      __index[name] = ->
        @\inc_counter(counter)

      -- decr
      name = 'decr_' .. counter
      __index[name] = ->
        @\decr_counter counter
    -- spawn collection methods
    for collection, model_fn in pairs @@collections
      -- the collection method
      __index[collection] =  (self) ->
        @\collection(collection)

      -- add method
      name = 'add_' .. collection
      __index[name] = (self, id) ->
        @\add_to_collection(collection, id)

      -- remove method
      name = 'remove_' .. collection
      __index[name] = (self, id) ->
        @\remove_from_collection(collection, id)

  key: =>
      @_key = @_key or @@\object_key(@id)
      @_key

  save: =>
    if not @id
      @@increment_counter!
      @id = @@counter!
    @@client\hmset(@key!, @\attributes!)

  attributes: =>
    tbl = {}

    for attr in *@@attrs
      tbl[attr] = @[attr]
    tbl

{ :Model }

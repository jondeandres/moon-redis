local Model
do
  local _parent_0 = nil
  local _base_0 = {
    counter_key_for = function(self, counter)
      return self:key() .. ':' .. counter
    end,
    get_counter = function(self, counter)
      local value = self.__class.client:get(self:counter_key_for(counter))
      return value or 0
    end,
    inc_counter = function(self, counter)
      return self.__class.client:incrby(self:counter_key_for(counter), 1)
    end,
    decr_counter = function(self, counter)
      return self.__class.client:decrby(self:counter_key_for(counter), 1)
    end,
    field_key = function(self, field)
      return self:key() .. ":" .. field
    end,
    collection = function(self, name)
      local collection = { }
      local collection_ids = self.__class.client:smembers(self:field_key(name))
      local relation_class = self.__class:relation_class_for('collections', name)
      local _list_0 = collection_ids
      for _index_0 = 1, #_list_0 do
        local id = _list_0[_index_0]
        local item = relation_class:get(id)
        table.insert(collection, item)
      end
      return collection
    end,
    add_to_collection = function(self, collection, id)
      return self.__class.client:sadd(self:field_key(collection), id)
    end,
    remove_from_collection = function(self, collection, id)
      return self.__class.client:srem(self:field_key(collection), id)
    end,
    spawn_methods = function(self)
      local __index = getmetatable(self).__index
      local _list_0 = self.__class.counters
      for _index_0 = 1, #_list_0 do
        local counter = _list_0[_index_0]
        local name = counter .. '_count'
        __index[name] = function()
          return self:get_counter(counter)
        end
        name = 'incr_' .. counter
        __index[name] = function()
          return self:inc_counter(counter)
        end
        name = 'decr_' .. counter
        __index[name] = function()
          return self:decr_counter(counter)
        end
      end
      for collection, model_fn in pairs(self.__class.collections) do
        __index[collection] = function(self)
          return self:collection(collection)
        end
        local name = 'add_' .. collection
        __index[name] = function(self, id)
          return self:add_to_collection(collection, id)
        end
        name = 'remove_' .. collection
        __index[name] = function(self, id)
          return self:remove_from_collection(collection, id)
        end
      end
    end,
    key = function(self)
      self._key = self._key or self.__class:object_key(self.id)
      return self._key
    end,
    save = function(self)
      if not self.id then
        self.__class:increment_counter()
        self.id = self.__class:counter()
      end
      return self.__class.client:hmset(self:key(), self:attributes())
    end,
    attributes = function(self)
      local tbl = { }
      local _list_0 = self.__class.attrs
      for _index_0 = 1, #_list_0 do
        local attr = _list_0[_index_0]
        tbl[attr] = self[attr]
      end
      return tbl
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, attributes)
      self:spawn_methods()
      if attributes then
        for attr, value in pairs(attributes) do
          self[attr] = value
        end
      end
    end,
    __base = _base_0,
    __name = "Model",
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
  self.primary_key = "id"
  self.model = nil
  self.counters = { }
  self.client = nil
  self.counter = function(self)
    return self.client:get(self:counter_key())
  end
  self.increment_counter = function(self)
    return self.client:incrby(self:counter_key(), 1)
  end
  self.relation_class_for = function(self, type, relation)
    return self[type][relation]()
  end
  self.counter_key = function(self)
    self._counter_key = self._counter_key or self.model .. ":count"
    return self._counter_key
  end
  self.object_key = function(self, id)
    return self.model .. ":" .. self.primary_key .. ":" .. id
  end
  self.get = function(self, id)
    local tbl = self.client:hgetall(self:object_key(id))
    tbl.id = id
    return self(tbl)
  end
  self.create = function(self, attributes)
    local item = self(attributes)
    item:save()
    return item
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Model = _class_0
end
return {
  Model = Model
}

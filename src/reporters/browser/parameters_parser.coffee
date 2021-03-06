
class spectacular.URLParameters
  constructor: (parameters) ->
    tuples = String(parameters).split('&').map((tuple) -> tuple.split('='))
    tuples.forEach ([key, value]) =>
      @consumeKeys this, @parseKey(key), @parseValue(value)

  parseKey: (key) ->
    key = key[0..-2] if key.substr(-1) is ']'
    key.split /\]*\[/g

  parseValue: (value) ->
    switch true
      when @isBoolean(value) then /true|on|yes/.test value
      when @isFloat(value) then parseFloat value
      when @isInteger(value) then parseInt value
      else value

  isBoolean: (value) -> /^(true|false|on|off|yes|no)$/.test String(value)
  isFloat: (value) -> /^\d+\.\d+$/.test String(value)
  isInteger: (value) -> /^\d+$/.test String(value)
  isArray: (a) -> Object::toString.call(a) is '[object Array]'

  consumeKeys: (target, keys, value) ->
    previousKey = null
    targets = [this]
    keys.forEach (key, index) =>
      keysRemains = keys.length - index > 1

      if @isInteger key
        if target[key]?
          if keysRemains
            target = target[key]
          else
            target[key].push value
        else
          if keysRemains
            o = {}
            target[key] = o
            target = o
          else
            target[key] = [value]

      else if key is ''
        target = targets[targets.length - 2]
        if @isArray target[previousKey]
          if keysRemains
            target = targets[previousKey]
          else
            target[previousKey].push value
        else
          if keysRemains
            target = target[previousKey] = []
          else
            target[previousKey] = [value]

      else
        if target[key]?
          if keysRemains
            target = target[key]
          else
            target[key] = value
        else
          if keysRemains
            target = target[key] = {}
          else
            target[key] = value

      targets.push(target)
      previousKey = key



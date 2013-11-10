spectacular.matchers ||= new spectacular.GlobalizableObject
spectacular.matchers.keepContext = false

spectacular.matcher = (name, block) ->
  o = new spectacular.GlobalizableObject
  takes = null
  match = null
  chains = {}
  timeout = null
  description = null
  init = null
  failureMessageForShould = null
  failureMessageForShouldnt = null

  def = (obj, prop, block) ->
    Object.defineProperty obj, prop, {
      value: block
      enumerable: true
      writable: true
      configurable: true
    }

  getter = (obj, prop, block) ->
    Object.defineProperty obj, prop, {
      get: block
      set: ->
      enumerable: true
      configurable: true
    }

  genChain = (matcher, key, block) ->
    f = ->
      o = Object.create(this)
      block.apply(o, arguments)
      o

    def matcher, key, f

  buildMatcher = (takes=[], args=[]) ->
    matcher = {name}
    if takes[0]? and takes[0].indexOf('...') isnt -1
      key = takes[0].replace /\.\.\./, ''
      matcher[key] = args
    else
      matcher[k] = args[i] for k,i in takes

    init?.call(matcher)

    matcher.match = (@actual) -> @result = match.apply(this, arguments)
    matcher.timeout = timeout
    matcher.formatValue = (value) ->
      spectacular.env?.options?.valueOutput?(value) or value


    genChain matcher, k, v for k,v of chains

    getter matcher, 'description', description if description?

    if failureMessageForShould?
      getter matcher, 'messageForShould', failureMessageForShould
    else
      getter matcher, 'messageForShould', -> @description

    if failureMessageForShouldnt?
      getter matcher, 'messageForShouldnt', failureMessageForShouldnt
    else if failureMessageForShould?
      getter matcher, 'messageForShouldnt', failureMessageForShould
    else
      getter matcher, 'messageForShouldnt', -> @description

    utils.snakify matcher
    matcher

  o.match = (value) -> match = value
  o.timeout = (value) -> timeout = value
  o.takes = (args...) -> takes = args
  o.chain = (chain, block) -> chains[chain] = block
  o.description = (block) -> description = block
  o.init = (block) -> init = block
  o.failureMessageForShould = (block) -> failureMessageForShould = block
  o.failureMessageForShouldnt = (block) -> failureMessageForShouldnt = block

  o.globalize()
  block.call(null)
  o.unglobalize()

  unless match?
    throw new Error "can't create matcher #{name} without a match"

  matcher = if takes?
    -> buildMatcher takes, (a for a in arguments)
  else
    buildMatcher()

  spectacular.matchers.set name, matcher


## Native Matchers

#### exist

spectacular.matcher 'exist', ->
  match (actual, notText) -> actual?

  description -> "exist"
  failureMessageForShould -> "Expected #{@formatValue @actual} to exist"
  failureMessageForShouldnt -> "Expected #{@formatValue @actual} to be undefined"


#### be

spectacular.matcher 'be', ->
  takes 'desc', 'value'
  description ->
    desc = if typeof @desc is 'string'
      @desc
    else
      @formatValue utils.squeeze utils.inspect @value

    "be #{desc}"

  failureMessageForShould ->
    switch typeof @value
      when 'string'
        "Expected #{@formatValue @actual} to #{@description} but was #{@formatValue @stateValue}"
      when 'number', 'boolean'
        "Expected #{@formatValue @actual} to #{@description}"
      else
        @message = "Expected #{@formatValue utils.inspect @actual} to #{@description}"

  failureMessageForShouldnt ->
    switch typeof @value
      when 'string'
        "Expected #{@formatValue @actual} not to #{@description} but was #{@formatValue @stateValue}"
      when 'number', 'boolean'
        "Expected #{@formatValue @actual} not to #{@description}"
      else
        @message = "Expected #{@formatValue utils.inspect @actual} not to #{@description}"

  match (actual) ->
    @value = @desc unless @value?

    switch typeof @value
      when 'string'
        @state = utils.findStateMethodOrProperty actual, @value

        if @state?
          if typeof actual[@state] is 'function'
            @stateValue = actual[@state]()
          else
            @stateValue = actual[@state]
        else
          @stateValue = false

        @stateValue
      when 'number', 'boolean'
        actual?.valueOf() is @value
      when 'function'
        if typeof @actual is 'function'
          actual is @value
        else
          actual?.constructor is @value
      else
        actual is @value


#### have

spectacular.matcher 'have', ->
  takes 'count', 'label'
  description -> "have #{@count} #{@label}"

  match (actual) ->
    switch typeof actual
      when 'string'
        actual.length is @count
      when 'object'
        if utils.isArray actual
          actual.length is @count
        else
          unless @label?
            throw new Error "Undefined label in have matcher"

          if actual[@label]
            if utils.isArray actual[@label]
              actual[@label].length is @count
            else false
          else false

      else false

  failureMessageForShould ->
    switch typeof @actual
      when 'string' then "Expected string #{@formatValue utils.inspect @actual} to #{@description} but was #{@formatValue @actual.length}"
      when 'object'
        if utils.isArray @actual
          "Expected array #{@formatValue utils.inspect @actual} to #{@description} but was #{@formatValue @actual.length}"
        else
          @message = "Expected object #{@formatValue utils.inspect @actual} to #{@description}"
      else
        @message = "Expected #{@formatValue utils.inspect @actual} to #{@description} but it don't belong to a type that can be handled"

  failureMessageForShouldnt ->
    switch typeof @actual
      when 'string' then "Expected string #{@formatValue utils.inspect @actual} not to #{@description} but was #{@formatValue @actual.length}"
      when 'object'
        if utils.isArray @actual
          "Expected array #{@formatValue utils.inspect @actual} not to #{@description} but was #{@formatValue @actual.length}"
        else
          @message = "Expected object #{@formatValue utils.inspect @actual} not to #{@description}"
      else
        @message = "Expected #{@formatValue utils.inspect @actual} not to #{@description} but it don't belong to a type that can be handled"


#### haveProperty

spectacular.matcher 'haveProperty', ->
  takes 'property'

  chain 'to', (@matcher) ->

  description ->
    desc = "have property #{@formatValue @property}"
    desc += ' to ' + @matcher.description if @matcher?
    desc

  match (actual) ->
    if @matcher?
      actual[@property]? and @matcher.match(actual[@property])
    else
      actual[@property]?

  failureMessageForShould ->
    desc = "Expected #{@formatValue utils.inspect @actual} to have a property #{@formatValue @property}"
    desc += ' to ' + @matcher.description if @matcher?
    desc

  failureMessageForShouldnt ->
    desc = "Expected #{@formatValue utils.inspect @actual} not to have a property #{@formatValue @property}"
    desc += ' to ' + @matcher.description if @matcher?
    desc


#### haveProperties

spectacular.matcher 'haveProperties', ->
  collectStrings = (col) -> col.filter (el) -> typeof el is 'string'
  collectHashs = (col) -> col.filter (el) -> typeof el is 'object'

  takes 'properties...'

  description ->
    stringProperties = collectStrings(@properties).map (v) => @formatValue v
    hashProperties = collectHashs @properties

    descs = []
    descs = descs.concat stringProperties
    hashProperties.forEach (item) =>
      for k,v of item
        descs.push "#{@formatValue k} to #{v.description}"

    desc = "have #{if descs.length > 1 then 'properties' else 'property'} "
    desc += utils.literalEnumeration(descs)

    desc

  match (actual) ->
    @matchers = []
    @properties.forEach (key) =>
      if typeof key is 'object'
        for k of key
          @matchers.push haveProperty(k).to(key[k])
      else
        @matchers.push haveProperty(key)

    res = true
    res = m.match(actual) and res for m in @matchers
    res

  failureMessageForShould ->
    @matchers?.filter((m) -> not m.success)
    .map((m) -> m.messageForShould)
    .join('\n')

  failureMessageForShouldnt ->
    @matchers?.filter((m) -> not m.success)
    .map((m) -> m.messageForShouldnt)
    .join('\n')


#### haveBeenCalled

spectacular.matcher 'haveBeenCalled', ->
  description ->
    msg = "have been called"
    msg += "with #{@formatValue utils.inspect @arguments}" if @arguments?
    msg

  chain 'with', (@arguments...) ->

  match (actual, notText) ->
    if typeof actual?.spied is 'function'
      if @arguments?
        actual.argsForCall.length > 0 and actual.argsForCall.some (a) =>
          equal(a).match(@arguments, '')
      else
        actual.argsForCall.length > 0
    else
      false

  failureMessageForShould ->
    if typeof @actual?.spied is 'function'
      if @arguments?
        "Expected #{@formatValue @actual.spied} to #{@description} but was called with #{@formatValue @actual.argsForCall}"
      else
        "Expected #{@formatValue @actual.spied} to have been called"
    else
      @message = "Expected a spy but it was #{@formatValue @actual}"

  failureMessageForShouldnt ->
    if typeof @actual?.spied is 'function'
      if @arguments?
        "Expected #{@formatValue @actual.spied} not to #{@description} but was called with #{@actual.argsForCall}"
      else
        "Expected #{@formatValue @actual.spied} not to have been called"
    else
      @message = "Expected a spy but it was #{@formatValue @actual}"


#### equal

spectacular.matcher 'equal', ->
  takes 'value'
  description -> "be equal to #{@formatValue utils.squeeze utils.inspect @value}"

  match (actual) ->
    @diff = diff: ''
    @result = utils.compare actual, @value, @diff

  failureMessageForShould ->
    msg = "Expected #{@formatValue utils.inspect @actual} to be equal to #{@formatValue utils.inspect @value}"
    msg += "\n\n#{@diff.diff}" if @diff?.diff.length > 0 and not @result

    msg

  failureMessageForShouldnt ->
    msg = "Expected #{@formatValue utils.inspect @actual} to be different than #{@formatValue utils.inspect @value}"
    msg += "\n\n#{@diff.diff}" if @diff?.diff.length > 0 and not @result
    msg


#### beWithin

spectacular.matcher 'beWithin', ->
  takes 'delta'

  description -> "be within #{@formatValue utils.squeeze utils.inspect @delta} of #{@formatValue utils.squeeze utils.inspect @expected}"

  chain 'of', (@expected) ->

  match (actual) -> @expected - @delta <= actual <= @expected + @delta

  failureMessageForShould -> "Expected #{@formatValue utils.inspect @actual} to #{@description}"

  failureMessageForShouldnt -> "Expected #{@formatValue utils.inspect @actual} not to #{@description}"


#### match

spectacular.matcher 'match', ->
  takes 're'
  description -> "match #{@formatValue @re}"

  match (actual) ->
    # The match matcher allow DOMExpression object as value
    if @re.match? and @re.contained?
      @re.match actual
    else if @re.test?
      @re.test actual
    else
      String(actual).indexOf(@re) isnt -1

  failureMessageForShould ->
    if @re.match? and @re.contained?
      "Expected #{@formatValue utils.descOfNode @actual} to match #{@formatValue @re}"
    else
      @message = "Expected #{@formatValue @actual} to match #{@formatValue @re}"

  failureMessageForShouldnt ->
    if @re.match? and @re.contained?
      "Expected #{@formatValue utils.descOfNode @actual} not to match #{@formatValue @re}"
    else
      @message = "Expected #{@formatValue @actual} not to match #{@formatValue @re}"


#### contains

spectacular.matcher 'contains', ->
  takes 'values...'
  description ->
    if @value?.match? and @value?.contained?
      "contains #{@formatValue @value}"
    else
      valuesDescription = utils.literalEnumeration @values.map (v) -> utils.inspect v
      "contains #{@formatValue valuesDescription}"

  match (actual) ->
    @value = @values[0]
    # The contains matcher allow DOMExpression object as value
    if @value?.match? and @value?.contained?
      @value.contained actual
    else
      @values.every (v) -> v in actual

  failureMessageForShould ->
    if @value?.match? and @value?.contained?
      "Expected #{@formatValue utils.descOfNode @actual} to contains #{@formatValue @value}"
    else
      valuesDescription = utils.literalEnumeration @values.map (v) -> utils.inspect v
      "Expected #{@formatValue utils.descOfNode @actual} to contains #{@formatValue valuesDescription}"

  failureMessageForShouldnt ->
    if @value?.match? and @value?.contained?
      "Expected #{@formatValue utils.descOfNode @actual} not to contains #{@formatValue @value}"
    else
      valuesDescription = utils.literalEnumeration @values.map (v) -> utils.inspect v
      "Expected #{@formatValue utils.descOfNode @actual} not to contains #{@formatValue valuesDescription}"


#### throwAnError

spectacular.matcher 'throwAnError', ->
  takes 'message'
  description ->
    msg = if @message? then " with message #{@formatValue @message}" else ''
    msg += " with arguments #{@formatValue utils.inspect @arguments}" if @arguments?
    msg += " in context #{@formatValue utils.inspect @context}" if @context?

    "throw an error#{msg}"

  chain 'with', (@arguments...) ->
  chain 'inContext', (@context) ->

  match (actual) ->
    try
      if @arguments?
        actual.apply @context, @arguments
      else
        actual.call @context
    catch err

    @error = err

    result = if @message?
      @error? and @message.test @error.message
    else
      @error?

    result

  failureMessageForShould -> "Expected to #{@description} but was #{@formatValue @error}"

  failureMessageForShouldnt -> "Expected not to #{@description} but was #{@formatValue @error}"



#### DOM Related

#### haveAttribute

spectacular.matcher 'haveAttribute', ->
  takes 'attribute'
  chain 'to', (@matcher) ->

  description ->
    desc = "have attribute #{@formatValue @attribute}"
    desc += ' to ' + @matcher.description if @matcher?
    desc

  match (actual) ->
    if @matcher?
      actual.hasAttribute(@attribute) and @matcher.match(actual.getAttribute(@attribute))
    else
      actual.hasAttribute(@attribute)

  failureMessageForShould ->
    desc = "Expected #{@formatValue utils.descOfNode @actual} to have an attribute #{@formatValue @attribute}"
    desc += ' to ' + @matcher.description if @matcher?
    desc

  failureMessageForShouldnt ->
    desc = "Expected #{@formatValue utils.descOfNode @actual} not to have an attribute #{@formatValue @attribute}"
    desc += ' to ' + @matcher.description if @matcher?
    desc


#### haveAttributes

spectacular.matcher 'haveAttributes', ->
  collectStrings = (col) -> col.filter (el) -> typeof el is 'string'
  collectHashs = (col) -> col.filter (el) -> typeof el is 'object'

  takes 'attributes...'

  description ->
    stringAttributes = collectStrings(@attributes).map (v) => @formatValue v
    hashAttributes = collectHashs @attributes

    descs = []
    descs = descs.concat stringAttributes
    hashAttributes.forEach (item) =>
      for k,v of item
        descs.push "#{@formatValue k} to #{v.description}"

    desc = "have #{if descs.length > 1 then 'attributes' else 'attribute'} "
    desc += utils.literalEnumeration(descs)

    desc

  match (actual) ->
    @matchers = []
    @attributes.forEach (key) =>
      if typeof key is 'object'
        for k of key
          @matchers.push haveAttribute(k).to(key[k])
      else
        @matchers.push haveAttribute(key)

    res = true
    res = m.match(actual) and res for m in @matchers
    res

  failureMessageForShould ->
    @matchers?.filter((m) -> not m.success)
    .map((m) -> m.messageForShould)
    .join('\n')

  failureMessageForShouldnt ->
    @matchers?.filter((m) -> not m.success)
    .map((m) -> m.messageForShouldnt)
    .join('\n')

#### haveClass

spectacular.matcher 'haveClass', ->
  takes 'className'
  description -> "have class #{@formatValue @className}"

  match (actual) ->
    classes = actual.getAttribute 'class'

    classes? and @className in classes.split(/\s+/g)

  failureMessageForShould ->
    "Expected #{@formatValue utils.descOfNode @actual} to #{@description}"

  failureMessageForShouldnt ->
    "Expected #{@formatValue utils.descOfNode @actual} not to #{@description}"

#### haveSelector

spectacular.matcher 'haveSelector', ->
  takes 'selector'
  description -> "have content that match #{@formatValue @selector}"

  match (actual) ->
    if actual.length?
      Array::some.call actual, (e) => e.querySelectorAll(@selector).length > 0
    else
      actual.querySelectorAll(@selector).length > 0

  failureMessageForShould ->
    "Expected #{@formatValue utils.descOfNode @actual} to have selector #{@formatValue @selector}"

  failureMessageForShouldnt ->
    "Expected #{@formatValue utils.descOfNode @actual} not to have selector #{@formatValue @selector}"


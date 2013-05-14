## Spectacular
spectacular = spectacular or {}

#### Core JS Extensions

String::capitalize = -> @replace /^(\w)/, (m, c) -> c.toUpperCase()

Function::include = (mixins...) ->
  excluded = ['constructor']
  for mixin in mixins
    @::[k] = v for k,v of mixin.prototype when k not in excluded
    mixin.included? this

  this

Function::extend = (mixins...) ->
  excluded = ['name', 'prototype']
  for mixin in mixins
    @[k] = v for k,v of mixin when k not in excluded
    mixin.extended? this

  this

Function::signature = ->
  re = ///
    ^function
    (\s+[a-zA-Z_][a-zA-Z0-9_]*)*
    \s*\(([^\)]+)\)
    ///
  re.exec(@toString())?[2].split(/\s*,\s*/) or []

Function::getter = (name, block) ->
  Object.defineProperty @prototype, name, {
    get: block
    configurable: true
    enumerable: true
  }
Function::setter = (name, block) ->
  Object.defineProperty @prototype, name, {
    set: block
    configurable: true
    enumerable: true
  }
Function::accessor = (name, options) ->
  Object.defineProperty @prototype, name, {
    get: options.get
    get: options.set
    configurable: true
    enumerable: true
  }

#### Mixins

class spectacular.HasAncestors
  ancestors: ->
    ancestors = []
    parent = @parent
    while parent
      ancestors.push parent
      parent = parent.parent
    ancestors

spectacular.HasCollection = (plural, singular) ->
  capitalizedSingular = singular.capitalize()
  capitalizedPlural = plural.capitalize()

  mixin = class ConcreteHasCollection
    @included: (ctor) ->
      ctor["#{plural}Scope"] = (name, block) ->
        ctor.getter name, -> @[plural].filter block

  mixin::["add#{capitalizedSingular}"] = (items...) ->
    @[plural].push item for item in items when item not in @[plural]

  mixin::["remove#{capitalizedSingular}"] = (items...) ->
    newArray = []
    newArray.push item for item in @[plural] when item not in items
    @[plural] = newArray

  mixin::["#{singular}At"] = (index) ->
    @[plural][index]

  mixin::["find#{capitalizedSingular}"] =
  mixin::["indexOf#{capitalizedSingular}"] = (item) ->
    @[plural].indexOf item

  mixin::["has#{capitalizedSingular}"] =
  mixin::["contains#{capitalizedSingular}"] = (item) ->
    @[plural].indexOf(item) isnt -1

  mixin::["#{plural}Length"] =
  mixin::["#{plural}Size"] =
  mixin::["#{plural}Count"] = ->
    @[plural].length

  mixin

spectacular.HasNestedCollection = (name, options={}) ->
  through = options.through
  throw new Error('missing through option') unless through?

  mixin = class ConcreteHasNestedCollection
    @included: (ctor) ->
      ctor["#{name}Scope"] = (scopeName, block) ->
        ctor.getter scopeName, -> @[name].filter block
      ctor.getter name, ->
        items = []
        @[through].forEach (item) ->
          items.push(item)
          items = items.concat(item[name]) if item[name]?
        items

  mixin



spectacular.FollowUpProperty = (property) ->
  capitalizedProperty = property.capitalize()
  privateProperty = "own#{capitalizedProperty}"
  class ConcreteFollowUpProperty
    @included: (ctor) ->
      ctor.getter property, -> @[privateProperty] or @parent?[property]

spectacular.MergeUpProperty = (property) ->
  capitalizedProperty = property.capitalize()
  privateProperty = "own#{capitalizedProperty}"
  class ConcreteMergeUpProperty
    @included: (ctor) ->
      ctor.getter property, ->
        a = @[privateProperty]
        a = @parent[property].concat a if @parent?
        a

spectacular.CollectUpProperty = (property, collect) ->
  class ConcreteCollectUpProperty
    @included: (ctor) ->
      ctor.getter property, ->
        a = collect this
        a = @parent[property].concat a if @parent?
        a

class spectacular.Describable
  @included: (ctor) ->
    ctor.getter 'description', ->
      if @parent?.description?
        space = ''
        space = ' ' unless @noSpaceBeforeDescription
        "#{@parent.description}#{space}#{@ownDescription}"
      else
        @ownDescription

#### Promise

class spectacular.Promise
  @unit: ->
    promise = new spectacular.Promise
    promise.resolve 0
    promise

  @all: (promises) ->
    promise = new spectacular.Promise
    solved = 0
    results = []

    promises.forEach (p) ->
      p
      .then (value) ->
        solved++
        results[promises.indexOf p] = value
        promise.resolve results if solved is promises.length

      .fail (reason) ->
        promise.reject reason

    promise

  constructor: ->
    @pending = true
    @fulfilled = null
    @value = undefined

    @fulfilledHandlers = []
    @errorHandlers = []
    @progressHandlers = []

  isPending: -> @pending
  isFulfilled: -> not @pending and @fulfilled
  isRejected: -> not @pending and not @fulfilled

  then: (fulfilledHandler, errorHandler, progressHandler) ->
    promise = new spectacular.Promise
    f = (value)->
      fulfilledHandler? value
      promise.resolve value
    e = (reason) ->
      errorHandler? reason
      promise.reject reason
    if @pending
      @fulfilledHandlers.push f
      @errorHandlers.push e
      @progressHandlers.push progressHandler if progressHandler?
    else
      if @fulfilled
        f @value
      else
        e @reason

    promise

  fail: (errorHandler) -> @then (->), errorHandler

  resolve: (@value) ->
    return unless @pending

    @fulfilled = true
    @notifyHandlers()
    @pending = false

  reject: (@reason) ->
    return unless @pending

    @fulfilled = false
    @notifyHandlers()
    @pending = false

  notifyHandlers: ->
    return unless @pending

    if @fulfilled
      handler @value for handler in @fulfilledHandlers
    else
      handler @reason for handler in @errorHandlers

class spectacular.AsyncExamplePromise extends spectacular.Promise
  constructor: ->
    @interval = null
    @timeout = 5000
    @message = 'Timed out'
    super()

  run: =>
    lastTime = new Date()
    @interval = setInterval =>
      if new Date() - lastTime >= @timeout
        clearInterval @interval
        @reject new Error @message
    , 10

  resolve: (value) ->
    clearInterval @interval
    super value

  rejectAfter: (@timeout, @message) ->

#### Expectation

class spectacular.Expectation
  constructor: (@example, @actual, @matcher, @not=false) ->
    try
      @success = @matcher.assert(@actual, if @not then ' not' else '')
      @success = not @success if @not
    catch e
      @success = false
      @trace = e
      @matcher.message = e.message unless @matcher.message?
      @matcher.description = '' unless @matcher.description?

    @message = @matcher.message
    unless @success
      try
        throw new Error
      catch e
        @trace = e

    @description = "#{@example.description} #{@matcher.description}"

#### ExampleResult

class spectacular.ExampleResult
  constructor: (@example, @state) ->
    @expectations = []

  hasFailures: -> @expectations.some (e) -> not e.success

#### Example

class spectacular.Example
  @include(
    spectacular.HasAncestors,
    spectacular.Describable,
    spectacular.FollowUpProperty('subjectBlock'),
    spectacular.MergeUpProperty('beforeHooks'),
    spectacular.MergeUpProperty('afterHooks'),
    spectacular.CollectUpProperty('dependencies', (e) ->
      e.options?.dependencies or []
    )
  )

  constructor: (@block, @ownDescription='', @parent) ->
    @noSpaceBeforeDescription = true if @ownDescription is ''
    @ownBeforeHooks = []
    @ownAfterHooks = []

  @getter 'subject', -> @__subject ||= @subjectBlock?.call(@context)

  pending: ->
    if @examplePromise?.pending
      @examplePromise.resolve()
      @result.state = 'pending'

  skip: ->
    if @examplePromise?.pending
      @examplePromise.reject new Error 'Skipped'
      @result.state = 'skipped'

  resolve: ->
    if @examplePromise?.pending
      if @result.hasFailures()
        @examplePromise.reject()
        @result.state = 'failure'
      else
        @examplePromise.resolve()
        @result.state = 'success'

  reject: (reason) ->
    if @examplePromise?.pending
      @examplePromise.reject reason
      @result.state = 'failure'

  createContext: ->
    context = {}
    Object.defineProperty context, 'subject', get: => @subject
    context

  run: ->
    @context = @createContext()

    @examplePromise = new spectacular.Promise
    afterPromise = new spectacular.Promise

    @result = new spectacular.ExampleResult this

    @runBefore (err) =>
      return @reject err if err?
      @executeBlock()

    @examplePromise.then => @runAfter (err) =>
      return afterPromise.reject err if err?
      afterPromise.resolve()
    @examplePromise.fail (reason) => @runAfter (err) =>
      return afterPromise.reject err if err?
      afterPromise.reject reason

    afterPromise

  runBefore: (callback) ->
    befores = @beforeHooks
    next = (err) =>
      return callback err if err?
      if befores.length is 0
        callback()
      else
        @executeHook befores.shift(), next

    next()

  runAfter: (callback) ->
    afters = @afterHooks
    next = (err) =>
      return callback err if err?
      if afters.length is 0
        callback()
      else
        @executeHook afters.shift(), next

    next()

  executeHook: (hook, next) ->
    try
      if @acceptAsync hook
        async = new spectacular.AsyncExamplePromise
        async.then => next()
        async.fail (reason) => next(reason)
        async.run()
        hook.call(@context, async)
      else
        hook.call(@context)
        next()
    catch e
      next(e)

  executeBlock: ->
    try
      if @acceptAsync @block
        async = new spectacular.AsyncExamplePromise
        async.then =>
          @resolve()
        async.fail (reason) =>
          @reject reason
        async.run()
        @block.call(@context, async)
      else
        @block.call(@context)
        @resolve()
    catch e
      @reject e

  toString: -> "[Example(#{@description})]"

  acceptAsync: (func) -> func.signature().length is 1

#### ExampleGroup

class spectacular.ExampleGroup extends spectacular.Example
  @include(
    spectacular.HasCollection('children', 'child'),
    spectacular.HasNestedCollection('descendants', through: 'children')
  )

  @childrenScope 'exampleGroups', (e) -> e.children?
  @childrenScope 'examples', (e) -> not e.children?
  @descendantsScope 'allExamples', (e) -> not e.children?
  @descendantsScope 'identifiedExamples', (e) -> e.options?.id?
  @getter 'identifiedExamplesMap', ->
    res = {}
    res[e.options.id] = e for e in @identifiedExamples
    res

  constructor: (block, desc, @parent, @options={}) ->
    subject = null
    switch typeof desc
      when 'string'
        if desc.indexOf('.') is 0
          @noSpaceBeforeDescription = true
          owner = @subject
          subject = owner?[desc.replace '.', '']
          subject = subject.bind(owner) if typeof subject is 'function'
          @ownSubjectBlock = => subject
        else if desc.indexOf('::') is 0
          @noSpaceBeforeDescription = true
          type = @subjectBlock?()
          @ownSubjectBlock = =>
            if type
              owner = build type, @parameters or []
              owner[desc.replace '::', ''].bind owner
        else
          @noSpaceBeforeDescription = true if @parent.description is ''

      else
        @noSpaceBeforeDescription = true
        subject = desc
        @ownSubjectBlock = => subject
        desc = subject?.name or subject?.toString() or ''

    super block, desc, @parent
    @children = []

  run: ->

  executeBlock: -> @block.call(this)

  toString: -> "[ExampleGroup(#{@description})]"


#### Spectacular Methods

rootExampleGroup = new spectacular.ExampleGroup
currentExampleGroup = rootExampleGroup
currentExample = null

notInsideIt = (method) ->
  throw new Error "#{method} called inside a it block" if currentExample?
notOutsideIt = (method) ->
  throw new Error "#{method} called outside a it block" unless currentExample?

spectacular.fail = -> throw new Error 'Failed'
spectacular.pending = -> currentExample.pending()
spectacular.skip = -> currentExample.skip()
spectacular.success = ->

spectacular.it = (msgOrBlock, block) ->
  notInsideIt 'it'

  [msgOrBlock, block] = ['', msgOrBlock] if typeof msgOrBlock is 'function'
  currentExampleGroup.addChild(
    new spectacular.Example block, msgOrBlock, currentExampleGroup
  )

spectacular.xit = (msgOrBlock, block) ->
  notInsideIt 'xit'

  if typeof msgOrBlock is 'string'
    it msgOrBlock, -> pending()
  else
    it -> pending()

spectacular.before = (block) ->
  notInsideIt 'before'
  currentExampleGroup.ownBeforeHooks.push block

spectacular.after = (block) ->
  notInsideIt 'after'
  currentExampleGroup.ownAfterHooks.push block

spectacular.its = (property, block) ->
  notInsideIt 'its'
  parentSubjectBlock = currentExampleGroup.subjectBlock
  spectacular.context "#{property} property", ->
    spectacular.subject property, -> parentSubjectBlock?()[property]
    spectacular.it block

spectacular.itsInstance = (block) ->
  notInsideIt 'itsInstance'

spectacular.itsReturn = (block) ->
  notInsideIt 'itsReturn'
  parentSubjectBlock = currentExampleGroup.subjectBlock
  spectacular.context 'returned value', ->
    spectacular.subject 'returnedValue', ->
      parentSubjectBlock?().apply(this, @parameters or [])

    spectacular.it block

spectacular.subject = (name, block) ->
  notInsideIt 'subject'
  [name, block] = [block, name] if typeof name is 'function'
  currentExampleGroup.ownSubjectBlock = block
  spectacular.given name, block if name?

spectacular.given = (name, block) ->
  notInsideIt 'given'

  spectacular.before ->
    Object.defineProperty this, name, {
      configurable: true
      enumerable: true
      get: block
    }

spectacular.describe = (subject, options, block) ->
  [options, block] = [block, options] if typeof options is 'function'
  notInsideIt 'describe'

  oldGroup = currentExampleGroup

  currentExampleGroup = new spectacular.ExampleGroup(
    block, subject, oldGroup, options
  )
  oldGroup.addChild currentExampleGroup

  currentExampleGroup.executeBlock()

  currentExampleGroup = oldGroup

spectacular.xdescribe = (subject, block) ->
  notInsideIt 'xdescribe'

spectacular.context = spectacular.describe
spectacular.xcontext = spectacular.xdescribe

spectacular.withParameters = (args...) ->
  notInsideIt 'withParameters'

  spectacular.given 'parameters', -> args

spectacular.dependsOn = (spec) ->
  currentExampleGroup.options.dependencies ||= []
  currentExampleGroup.options.dependencies.push spec

Object.defineProperty Object.prototype, 'should', {
  writable: true,
  enumerable: false,
  value: (matcher) ->
    notOutsideIt 'should'

    currentExample.result.expectations.push(
      new spectacular.Expectation(
        currentExample,
        this,
        matcher,
        false
      )
    )
}

Object.defineProperty Object.prototype, 'shouldnt', {
  writable: true,
  enumerable: false,
  value: (matcher) ->
    notOutsideIt 'should'

    currentExample.result.expectations.push(
      new spectacular.Expectation(
        currentExample,
        this,
        matcher,
        true
      )
    )
}

spectacular.should = (matcher, neg=false) ->
  notOutsideIt 'should'

  currentExample.result.expectations.push(
    new spectacular.Expectation(
      currentExample,
      currentExample.subject,
      matcher,
      neg
    )
  )

spectacular.shouldnt = (matcher) ->
  should matcher, true


'it xit describe xdescribe context xcontext
  before after given subject its itsInstance
  itsReturn withParameters fail pending success
  skip should shouldnt dependsOn
'.split(/\s+/g).forEach (k) ->
  global[k] = spectacular[k]







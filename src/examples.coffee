
## Expectation

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
    if not @success and not @trace?
      try
        throw new Error
      catch e
        stack = e.stack.split('\n')
        e.stack = stack[3..].join('\n')
        @trace = e

    @description = "#{@example.description} #{@matcher.description}"

## ExampleResult

class spectacular.ExampleResult
  constructor: (@example, @state) ->
    @expectations = []

  hasFailures: -> @expectations.some (e) -> not e.success

## Example

class spectacular.Example
  @include spectacular.HasAncestors
  @include spectacular.Describable
  @include spectacular.FollowUpProperty('subjectBlock')
  @include spectacular.MergeUpProperty('beforeHooks')
  @include spectacular.MergeUpProperty('afterHooks')
  @include spectacular.MergeUpProperty('dependencies')

  constructor: (@block, @ownDescription='', @parent) ->
    @noSpaceBeforeDescription = true if @ownDescription is ''
    @ownBeforeHooks = []
    @ownAfterHooks = []
    @ownDependencies = []

  @getter 'subject', -> @__subject ||= @subjectBlock?.call(@context)
  @getter 'finished', -> @examplePromise?.isResolved()
  @getter 'failed', -> @examplePromise?.isRejected()
  @getter 'succeed', -> @examplePromise?.isFulfilled()

  @ancestorsScope 'identifiedAncestors', (e) -> e.options.id?

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

  stop: (reason) ->
    if @examplePromise?.pending
      @examplePromise.reject reason
      @result.state = 'stopped'

  createContext: ->
    context = {}
    Object.defineProperty context, 'subject', get: => @subject
    context

  dependenciesMet: -> true

  run: ->
    @context = @createContext()
    @examplePromise = new spectacular.Promise
    @result = new spectacular.ExampleResult this

    return @skip() and @examplePromise unless @dependenciesMet()

    afterPromise = new spectacular.Promise

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
      @stop e

  toString: -> "[Example(#{@description})]"

  acceptAsync: (func) -> func.signature().length is 1

## ExampleGroup

class spectacular.ExampleGroup extends spectacular.Example
  @include spectacular.HasCollection('children', 'child')
  @include spectacular.HasNestedCollection('descendants', through: 'children')

  @childrenScope 'exampleGroups', (e) -> e.children?
  @childrenScope 'examples', (e) -> not e.children?
  @descendantsScope 'allExamples', (e) -> not e.children?
  @descendantsScope 'identifiedExamples', (e) -> e.options?.id?
  @getter 'identifiedExamplesMap', ->
    res = {}
    res[e.options.id] = e for e in @identifiedExamples
    res
  @getter 'finished', -> @allExamples.every (e) -> e.finished
  @getter 'failed', -> @allExamples.some (e) -> e.failed
  @getter 'succeed', -> not @failed

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


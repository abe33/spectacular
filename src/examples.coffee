
## Expectation

class spectacular.Expectation
  constructor: (@example, @actual, @matcher, @not=false) ->

  assert: =>
    promise = new spectacular.Promise
    timeout = null
    try
      assert = spectacular.Promise.unit()
      .then =>
        timeout = setTimeout =>
          @success = false
          @trace = new Error 'matcher timed out'
          @message = @matcher.message
          @description = @matcher.description
          promise.reject @success
        , @matcher.timeout or 5000

        @matcher.assert(@actual, if @not then ' not' else '')
      .then (@success) =>
        clearTimeout timeout
        @success = not @success if @not
        @createMessage()
        promise.resolve @success
      .fail (@trace) =>
        clearTimeout timeout
        @success = false
        @matcher.message = @trace.message unless @matcher.message?
        @matcher.description = '' unless @matcher.description?
        promise.resolve @success
    catch e
      clearTimeout timeout
      @success = false
      @trace = e
      @matcher.message = e.message unless @matcher.message?
      @matcher.description = '' unless @matcher.description?
      promise.resolve @success

    promise

  createMessage: =>
    @message = @matcher.message
    if not @success and not @trace?
      try
        throw new Error
      catch e
        stack = e.stack.split('\n')
        specIndex = spectacular.env.runner.findSpecFileInStack stack
        e.stack = stack[specIndex..].join('\n') if specIndex isnt -1
        @trace = e

    @description = "#{@example.description} #{@matcher.description}"

## ExampleResult

class spectacular.ExampleResult
  @include spectacular.HasCollection('expectations', 'expectation')

  constructor: (@example, @state) ->
    @expectations = []
    @promise = spectacular.Promise.unit()

  hasFailures: -> @expectations.some (e) -> not e.success

  _addExpectation = ExampleResult::addExpectation
  addExpectation: (expectation) ->
    handler = -> expectation.assert()
    @promise = @promise.then handler, handler
    _addExpectation.call this, expectation


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
      @result.state = 'pending'
      @examplePromise.resolve()

  skip: ->
    if @examplePromise?.pending
      @result.state = 'skipped'
      @examplePromise.reject new Error 'Skipped'

  resolve: =>
    if @examplePromise?.pending
      if @result.hasFailures()
        @result.state = 'failure'
        @examplePromise.reject()
      else if @result.expectationsCount() is 0
        @result.state = 'pending'
        @examplePromise.resolve()
      else
        @result.state = 'success'
        @examplePromise.resolve()

  reject: (reason) =>
    if @examplePromise?.pending
      @result.state = 'failure'
      @examplePromise.reject reason

  error: (reason) ->
    if @examplePromise?.pending
      @result.state = 'errored'
      @examplePromise.reject reason

  createContext: ->
    context = {}
    Object.defineProperty context, 'subject', get: => @subject
    context

  dependenciesMet: -> true

  run: ->
    @context = @createContext()
    @examplePromise = new spectacular.Promise
    @result = new spectacular.ExampleResult this

    unless @dependenciesMet()
      @skip()
      @examplePromise

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
        async = new spectacular.AsyncPromise
        async.then => next()
        async.fail (reason) =>
          next reason
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
        async = new spectacular.AsyncPromise
        async.then @executeExpectations, @reject
        async.run()
        @block.call(@context, async)
      else
        @block.call(@context)
        @executeExpectations()
    catch e
      @error e

  executeExpectations: =>
    @result.promise.then @resolve, @reject

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

        desc = subject?.name or subject?._name or subject?.toString() or ''

    super block, desc, @parent
    @children = []

  run: ->

  executeBlock: -> @block.call(this)

  toString: -> "[ExampleGroup(#{@description})]"


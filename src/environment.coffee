spectacular.helpers = new spectacular.GlobalizableObject

spectacular.helper = (name, value) -> spectacular.helpers.set name, value

class spectacular.Environment
  @include spectacular.Globalizable

  constructor: (@options) ->
    @globalizable = 'it xit describe xdescribe expect
      before after given subject its itsInstance itsReturn
      withParameters fail pending success skip should shouldnt
      dependsOn spyOn whenPass fixture except only sharedExample
      itBehavesLike'.split(/\s+/g)

    @rootExampleGroup = new spectacular.ExampleGroup null, ''
    @currentExampleGroup = @rootExampleGroup
    @currentExample = null
    @runner = new spectacular.Runner(@rootExampleGroup, @options, this)
    @sharedExamples = {}

    @createExampleAlias 'the'
    @createExampleAlias 'specify'

    @createExampleGroupAlias 'context'
    @createOuterExampleAlias 'xcontext', 'xdescribe'
    @createOuterExampleAlias 'withArguments', 'withParameters'
    @createOuterExampleAlias 'itShould', 'itBehavesLike'

    @registerFixtureHandler 'json', @handleJSONFixture
    @registerFixtureHandler 'html', @handleHTMLFixture
    @registerFixtureHandler 'dom', @handleDOMFixture

  run: => @runner.run()

  @_globalize = Environment::globalize
  @_unglobalize = Environment::unglobalize

  createGlobalizedMethod: (name, block) ->
    unless name in @globalizable
      @globalizable.push name
      @[name] = block

      @globalizeMember name, block if @globalized

  createExampleGroupAlias: (name) -> @createOuterExampleAlias name, 'describe'
  createExampleAlias: (name) -> @createOuterExampleAlias name, 'it'

  createInnerExampleAlias: (newName, oldName) ->
    @createGlobalizedMethod newName, ->
      @notOutsideIt newName

      @[oldName].apply this, arguments

  createOuterExampleAlias: (newName, oldName) ->
    @createGlobalizedMethod newName, ->
      @notInsideIt newName

      @[oldName].apply this, arguments

  globalize: ->
    Environment._globalize.call(this)
    spectacular.factories.globalize()
    spectacular.matchers.globalize()
    spectacular.helpers.globalize()
    @globalizeObjectExtensions()

  unglobalize: ->
    Environment._unglobalize.call(this)
    spectacular.factories.unglobalize()
    spectacular.matchers.unglobalize()
    spectacular.helpers.unglobalize()
    @unglobalizeObjectExtensions()

  unglobalizeObjectExtensions: ->
    delete Object::should
    delete Object::shouldnt
    delete spectacular.global.should
    delete spectacular.global.shouldnt

  globalizeObjectExtensions: ->
    env = this
    Object.defineProperty Object.prototype, 'should', {
      writable: true
      configurable: true
      enumerable: false
      value: (matcher, neg=false) ->
        env.notOutsideIt 'should'

        return unless matcher?
        env.currentExample.result.addExpectation(
          new spectacular.Expectation(
            env.currentExample,
            @valueOf(),
            matcher,
            neg,
            new Error
          )
        )
    }

    Object.defineProperty Object.prototype, 'shouldnt', {
      writable: true
      configurable: true
      enumerable: false
      value: (matcher) ->
        env.notOutsideIt 'should'
        @should matcher, true
    }

  clone: ->
    optionsCopy = {}
    optionsCopy[k] = v for k,v of @options
    new spectacular.Environment optionsCopy

  notInsideIt: (method) ->
    if @currentExample?
      throw new Error "#{method} called inside a it block"
  notOutsideIt: (method) ->
    unless @currentExample?
      throw new Error "#{method} called outside a it block"

   notWihoutMatcher: (method) ->
    throw new Error "#{method} called without a matcher"

  fail: -> @currentExample.reject new Error 'Failed'
  pending: -> @currentExample.pending()
  skip: -> @currentExample.skip()
  success: ->

  it: (msgOrBlock, block) ->
    @notInsideIt 'it'

    [msgOrBlock, block] = ['', msgOrBlock] if typeof msgOrBlock is 'function'
    example = new spectacular.Example block, msgOrBlock, @currentExampleGroup
    @currentExampleGroup.addChild example
    example

  xit: (msgOrBlock, block) ->
    @notInsideIt 'xit'

    if typeof msgOrBlock is 'string'
      @it msgOrBlock, -> pending()
    else
      @it -> pending()

  before: (block) ->
    @notInsideIt 'before'
    @currentExampleGroup.ownBeforeHooks.push block

  after: (block) ->
    @notInsideIt 'after'
    @currentExampleGroup.ownAfterHooks.push block

  its: (property, block) ->
    @notInsideIt 'its'
    parentSubjectBlock = @currentExampleGroup.subjectBlock
    @context "#{property} property", =>
      @subject property, -> parentSubjectBlock?.call(this)[property]
      @it block

  itsInstance: (property, options, block) ->
    @notInsideIt 'itsInstance'

    if typeof property is 'function'
      [property, options, block] = [block, {}, property]
    else if typeof property is 'object'
      [property, options, block] = [null, property, options]
    else if typeof options is 'function'
      [options, block] = [{}, options]

    parentSubjectBlock = @currentExampleGroup.subjectBlock
    unless parentSubjectBlock?
      throw new Error 'itsInstance called in context without a previous subject'

    @context 'instance', =>
      @subject 'instance', ->
        params = if options.with?
         if typeof options.with is 'function'
            options.with.call(this)
          else
            options.with
        else
          @parameters or []

        build parentSubjectBlock?.call(this), params

      if property?
        @its property, block
      else
        @it block

  itsReturn: (options, block) ->
    @notInsideIt 'itsReturn'

    [block, options] = [options, {}] if typeof options is 'function'

    parentSubjectBlock = @currentExampleGroup.subjectBlock
    unless parentSubjectBlock?
      throw new Error 'itsReturn called in context without a previous subject'

    @context 'returned value', =>
      @subject 'returnedValue', ->
        context = if options.inContext? or options.in_context?
          ctx = options.inContext or options.in_context
          if typeof ctx is 'function'
            ctx.call(this)
          else
            ctx
        else
          this

        params = if options.with?
         if typeof options.with is 'function'
            options.with.call(this)
          else
            options.with
        else
          @parameters or []
        parentSubjectBlock?.call(this).apply(context, params)

      @it block

  subject: (name, block) ->
    @notInsideIt 'subject'
    [name, block] = [block, name] if typeof name is 'function'
    subjectBlock = ->
      @["__#{name or 'subject'}"] ||= block.call this
    @currentExampleGroup.ownSubjectBlock = subjectBlock
    @given name, subjectBlock if name?

  given: (name, block) ->
    @notInsideIt 'given'

    @before ->
      Object.defineProperty this, name, {
        configurable: true
        enumerable: true
        get: -> @["__#{name}"] ||= block.call(this)
      }

  describe: (subject, options, block) ->
    [options, block] = [block, options] if typeof options is 'function'
    @notInsideIt 'describe'

    oldGroup = @currentExampleGroup

    @currentExampleGroup = currentGroup = new spectacular.ExampleGroup(
      block, subject, oldGroup, options
    )
    oldGroup.addChild @currentExampleGroup

    try
      @currentExampleGroup.executeBlock()
    catch error
    finally
      @currentExampleGroup = oldGroup
      throw error if error?

    currentGroup

  xdescribe: (subject, options, block) ->
    @notInsideIt 'xdescribe'

    [options, block] = [block, options] if typeof options is 'function'

    describe subject, -> it -> pending()

  withParameters: (args...) ->
    @notInsideIt 'withParameters'

    @given 'parameters', ->
      if typeof args[0] is 'function'
        args[0].call(this)
      else
        args

  dependsOn: (spec) ->
    @notInsideIt 'dependsOn'

    @currentExampleGroup.ownDependencies.push spec

  whenPass: (block) ->
    @notInsideIt 'whenPass'

    previousContext = @currentExampleGroup
    @context '', =>
      @currentExampleGroup.ownCascading = previousContext
      block()

  spyOn: (obj, method) ->
    @notOutsideIt 'spyOn'

    oldMethod = obj[method]
    context = @currentExample.context

    spy = (args...) ->
      spy.argsForCall.push args
      if spy.mock?
        spy.mock.apply(obj, args)
      else
        oldMethod.apply(obj, args)

    spy.spied = oldMethod
    spy.argsForCall = []
    spy.andCallFake = (@mock) -> this
    spy.andReturns = (value) -> spy.andCallFake -> value
    spy.andCallThrough = (block) ->
      @mock = ->
        block.call context, oldMethod.apply this, arguments
      this

    utils.snakify spy

    @currentExample.ownAfterHooks.push ->
      obj[method] = oldMethod

    obj[method] = spy
    spy

  should: (matcher, neg=false) ->
    @notOutsideIt 'should'
    @notWihoutMatcher 'should' unless matcher?

    @currentExample.result.addExpectation(
      new spectacular.Expectation(
        @currentExample,
        @currentExample.subject,
        matcher,
        neg,
        new Error
      )
    )

  shouldnt: (matcher) -> @should matcher, true

  expect: (desc, value) ->
    value = desc if not value? and arguments.length < 2

    @notOutsideIt 'expect'
    self = this
    err = new Error

    to: (matcher) ->
      self.notWihoutMatcher 'expect(...).to' unless matcher?

      self.currentExample.result.addExpectation(
        new spectacular.Expectation(
          self.currentExample,
          value,
          matcher,
          false,
          err,
          desc
        )
      )
    not:
      to: (matcher) ->
        self.notWihoutMatcher 'expect(...).not.to' unless matcher?

        self.currentExample.result.addExpectation(
          new spectacular.Expectation(
            self.currentExample,
            value,
            matcher,
            true,
            err,
            desc
          )
        )

  except: (example) -> example.inclusive = true
  only: (example) -> example.exclusive = true

  sharedExample: (name, block) ->
    if name of @sharedExamples
      throw new Error "shared example '#{name}' already registered"
    @sharedExamples[name] = block

  itBehavesLike: (name, options={}) ->
    unless name of @sharedExamples
      throw new Error "shared example '#{name}' not found"
    @sharedExamples[name].call null, options

  fixture: (file, options={}) ->
    @notInsideIt 'fixture'

    name = options.as or 'fixture'
    env = this
    envOptions = @options
    ext = file.split('.')[-1..][0]
    @before (async) ->
      p = "#{envOptions.fixturesRoot}/#{file}"
      envOptions.loadFile(p)
      .then (fileContent) =>
        env.handleFixture(ext, fileContent).then (result) =>
          @[name] = result
          async.resolve()
      .fail (reason) ->
        async.reject reason

  registerFixtureHandler: (ext, proc) ->
    @fixtureHandlers ||= {}
    @fixtureHandlers[ext] = proc

  handleFixture: (ext, content) ->
    if ext of @fixtureHandlers
      @fixtureHandlers[ext].call this, content
    else
      spectacular.Promise.unit(content)

  handleJSONFixture: (content) ->
    spectacular.Promise.unit JSON.parse content

  handleDOMFixture: (content) ->
    spectacular.Promise.unit new spectacular.dom.DOMExpression content

  handleHTMLFixture: (content) ->
    parent = document.querySelector '#fixtures'
    unless parent?
      body = document.querySelector('body')
      fixtures = document.createElement('div')
      fixtures.id = 'fixtures'
      body.appendChild fixtures

    parent = document.querySelector '#fixtures'
    parent.innerHTML = content

    @currentExample.ownAfterHooks.push -> parent.innerHTML = ''

    spectacular.Promise.unit parent.childNodes


  toString: -> '[spectacular Environment]'

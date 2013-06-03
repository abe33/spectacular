
class spectacular.Environment
  @include spectacular.Globalizable

  Object.defineProperty this, 'EXPOSED_PROPERTIES', get: ->
    'it xit describe xdescribe context xcontext
    before after given subject its itsInstance itsReturn
    withParameters fail pending success skip should shouldnt
    dependsOn spyOn the withArguments whenPass fixture specify
    except only sharedExample'.split ' '

  exposedSpectacularMethods:
    build: spectacular.factories.build
    factory: spectacular.factories.factory
    create: spectacular.factories.create

  constructor: (@options) ->
    @rootExampleGroup = new spectacular.ExampleGroup
    @currentExampleGroup = @rootExampleGroup
    @currentExample = null
    @runner = new spectacular.Runner(@rootExampleGroup, @options, this)
    @registerFixtureHandler 'json', @handleJSONFixture
    @registerFixtureHandler 'html', @handleHTMLFixture
    @registerFixtureHandler 'dom', @handleDOMFixture

  run: => @runner.run()

  _globalize = Environment::globalize
  globalize: =>
    _globalize.call(this)
    @loadObjectExtensions()
    @loadSpectacularMethods()
    @loadSpectacularMatchers()
    @loadJQuery()

  loadSpectacularMatchers: ->
    for k,v of spectacular.matchers
      v._name = k
      spectacular.global[k] = v

  loadSpectacularMethods: ->
    for k,v of @exposedSpectacularMethods
      v._name = k
      spectacular.global[k] = v

  loadJQuery: ->
    spectacular.global.$ = @options.jQuery

  loadObjectExtensions: ->
    env = this
    Object.defineProperty Object.prototype, 'should', {
      writable: true,
      enumerable: false,
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
      writable: true,
      enumerable: false,
      value: (matcher) ->
        env.notOutsideIt 'should'
        @should matcher, true
    }

  clone: ->
    optionsCopy = {}
    optionsCopy[k] = v for k,v of @options
    new spectacular.Environment optionsCopy

  notInsideIt: (method) =>
    if @currentExample?
      throw new Error "#{method} called inside a it block"
  notOutsideIt: (method) =>
    unless @currentExample?
      throw new Error "#{method} called outside a it block"

  fail: => @currentExample.reject new Error 'Failed'
  pending: => @currentExample.pending()
  skip: => @currentExample.skip()
  success: =>

  it: (msgOrBlock, block) =>
    @notInsideIt 'it'

    [msgOrBlock, block] = ['', msgOrBlock] if typeof msgOrBlock is 'function'
    example = new spectacular.Example block, msgOrBlock, @currentExampleGroup
    @currentExampleGroup.addChild example
    example

  the: (msgOrBlock, block) =>
    @notInsideIt 'the'
    @it msgOrBlock, block

  specify: (msgOrBlock, block) =>
    @notInsideIt 'specify'
    @it msgOrBlock, block

  xit: (msgOrBlock, block) =>
    @notInsideIt 'xit'

    if typeof msgOrBlock is 'string'
      @it msgOrBlock, -> pending()
    else
      @it -> pending()

  before: (block) =>
    @notInsideIt 'before'
    @currentExampleGroup.ownBeforeHooks.push block

  after: (block) =>
    @notInsideIt 'after'
    @currentExampleGroup.ownAfterHooks.push block

  its: (property, block) =>
    @notInsideIt 'its'
    parentSubjectBlock = @currentExampleGroup.subjectBlock
    @context "#{property} property", =>
      @subject property, -> parentSubjectBlock?.call(this)[property]
      @it block

  itsInstance: (property, block) =>
    @notInsideIt 'itsInstance'

    [property, block] = [block, property] if typeof property is 'function'
    parentSubjectBlock = @currentExampleGroup.subjectBlock
    @context 'instance', =>
      @subject 'instance', ->
        build parentSubjectBlock?.call(this), @parameters or []

      if property?
        @its property, block
      else
        @it block

  itsReturn: (options, block) =>
    @notInsideIt 'itsReturn'

    [block, options] = [options, {}] if typeof options is 'function'
    parentSubjectBlock = @currentExampleGroup.subjectBlock
    @context 'returned value', =>
      @subject 'returnedValue', ->
        parentSubjectBlock?.call(this).apply(options.inContext or this,
                                             options.with or @parameters or [])

      @it block

  subject: (name, block) =>
    @notInsideIt 'subject'
    [name, block] = [block, name] if typeof name is 'function'
    @currentExampleGroup.ownSubjectBlock = block
    @given name, block if name?

  given: (name, block) =>
    @notInsideIt 'given'

    @before ->
      Object.defineProperty this, name, {
        configurable: true
        enumerable: true
        get: -> @["__#{name}"] ||= block.call(this)
      }

  describe: (subject, options, block) =>
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


  xdescribe: (subject, options, block) =>
    @notInsideIt 'xdescribe'

    [options, block] = [block, options] if typeof options is 'function'

    describe subject, -> it -> pending()

  context: (subject, options, block) =>
    @notInsideIt 'context'

    @describe subject, options, block

  xcontext: (subject, options, block)  =>
    @notInsideIt 'xcontext'

    @xdescribe subject, options, block

  withParameters: (args...) =>
    @notInsideIt 'withParameters'

    @given 'parameters', ->
      if typeof args[0] is 'function'
        args[0].call(this)
      else
        args

  withArguments: =>
    @notInsideIt 'withArguments'

    @withParameters.apply this, arguments

  dependsOn: (spec) =>
    @notInsideIt 'dependsOn'

    @currentExampleGroup.ownDependencies.push spec

  whenPass: (block) =>
    @notInsideIt 'whenPass'

    previousContext = @currentExampleGroup
    @context '', =>
      @currentExampleGroup.ownCascading = previousContext
      block()

  spyOn: (obj, method) =>
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

    @currentExample.ownAfterHooks.push ->
      obj[method] = oldMethod

    obj[method] = spy
    spy

  fixture: (file, options={}) =>
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
    content = $(content)
    parent = $('<div id="fixtures"></div>')
    parent.append content
    $('body').append parent

    @currentExample.ownAfterHooks.push ->
      parent.remove()

    spectacular.Promise.unit content


  should: (matcher, neg=false) =>
    @notOutsideIt 'should'

    return unless matcher?
    @currentExample.result.addExpectation(
      new spectacular.Expectation(
        @currentExample,
        @currentExample.subject,
        matcher,
        neg,
        new Error
      )
    )

  shouldnt: (matcher) => @should matcher, true

  except: (example) -> example.inclusive = true
  only: (example) -> example.exclusive = true


  toString: -> '[spectacular Environment]'

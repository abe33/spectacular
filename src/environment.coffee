
class spectacular.Environment
  exposedMethods:'it xit describe xdescribe context xcontext
    before after given subject its itsInstance
    itsReturn withParameters fail pending success
    skip should shouldnt dependsOn spyOn the
    withArguments whenPass'

  constructor: (@options) ->
    @rootExampleGroup = new spectacular.ExampleGroup
    @currentExampleGroup = @rootExampleGroup
    @currentExample = null
    @runner = new spectacular.Runner(@rootExampleGroup, @options, this)

  run: => @runner.run()

  load: =>
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

    @exposedMethods.split(/\s+/g).forEach (k) =>
      fn = -> env[k].apply env, arguments
      fn._name = k
      spectacular.global[k] = fn

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
    @currentExampleGroup.addChild(
      new spectacular.Example block, msgOrBlock, @currentExampleGroup
    )

  the: (msgOrBlock, block) => @it msgOrBlock, block

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
      @subject property, -> parentSubjectBlock?()[property]
      @it block

  itsInstance: (block) =>
    @notInsideIt 'itsInstance'

    parentSubjectBlock = @currentExampleGroup.subjectBlock
    @context 'instance', =>
      @subject 'instance', ->
        build parentSubjectBlock?(), @parameters or []

      @it block

  itsReturn: (block) =>
    @notInsideIt 'itsReturn'
    parentSubjectBlock = @currentExampleGroup.subjectBlock
    @context 'returned value', =>
      @subject 'returnedValue', ->
        parentSubjectBlock?().apply(this, @parameters or [])

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
        get: => @["__#{name}"] ||= block.call(this)
      }

  describe: (subject, options, block) =>
    [options, block] = [block, options] if typeof options is 'function'
    @notInsideIt 'describe'

    oldGroup = @currentExampleGroup

    @currentExampleGroup = new spectacular.ExampleGroup(
      block, subject, oldGroup, options
    )
    oldGroup.addChild @currentExampleGroup

    try
      @currentExampleGroup.executeBlock()
    catch error
    finally
      @currentExampleGroup = oldGroup
      throw error if error?


  xdescribe: (subject, block) =>
    @notInsideIt 'xdescribe'

    describe subject, -> it -> pending()

  context: (subject, options, block) =>
    @notInsideIt 'context'
    @describe subject, options, block
  xcontext: =>
    @notInsideIt 'xcontext'
    @xdescribe()

  withParameters: (args...) =>
    @notInsideIt 'withParameters'

    @given 'parameters', -> args

  withArguments: => @withParameters.apply this, arguments

  dependsOn: (spec) =>
    @currentExampleGroup.ownDependencies.push spec

  whenPass: (block) =>
    previousContext = @currentExampleGroup
    @context '', =>
      @currentExampleGroup.ownCascading = previousContext
      block()

  spyOn: (obj, method) =>
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

  toString: -> '[spectacular Environment]'


class spectacular.Environment
  constructor: (@Runner, @Formatter, @options) ->
    @rootExampleGroup = new spectacular.ExampleGroup
    @currentExampleGroup = @rootExampleGroup
    @currentExample = null
    @formatter = new @Formatter(@rootExampleGroup, @options, this)
    @runner = new @Runner(@rootExampleGroup, @options, this, @formatter)

  run: =>
    @load()
    @runner.run()

  load: =>
    env = this
    Object.defineProperty Object.prototype, 'should', {
      writable: true,
      enumerable: false,
      value: (matcher) ->
        env.notOutsideIt 'should'

        env.currentExample.result.expectations.push(
          new spectacular.Expectation(
            env.currentExample,
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
        env.notOutsideIt 'should'

        env.currentExample.result.expectations.push(
          new spectacular.Expectation(
            env.currentExample,
            this,
            matcher,
            true
          )
        )
    }

    'it xit describe xdescribe context xcontext
      before after given subject its itsInstance
      itsReturn withParameters fail pending success
      skip should shouldnt dependsOn spyOn the'.split(/\s+/g).forEach (k) =>
      global[k] = ->
        env[k].apply env, arguments

  clone: ->
    optionsCopy = {}
    optionsCopy[k] = v for k,v of @options
    new spectacular.Environment @Runner, @Formatter, optionsCopy

  notInsideIt: (method) =>
    if @currentExample?
      throw new Error "#{method} called inside a it block"
  notOutsideIt: (method) =>
    unless @currentExample?
      throw new Error "#{method} called outside a it block"

  fail: => throw new Error 'Failed'
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

  context: (subject, options, block) => @describe subject, options, block
  xcontext: => @xdescribe()

  withParameters: (args...) =>
    @notInsideIt 'withParameters'

    @given 'parameters', -> args

  dependsOn: (spec) =>
    @currentExampleGroup.ownDependencies.push spec

  spyOn: (obj, method) =>
    oldMethod = obj[method]
    spy = (args...) ->
      spy.argsForCall.push args
      if spy.mock?
        spy.mock.apply(obj, args)
      else
        oldMethod.apply(obj, args)

    spy.spied = oldMethod
    spy.argsForCall = []
    spy.andCallFake = (@mock) -> this

    @currentExample.ownAfterHooks.push ->
      obj[method] = oldMethod

    obj[method] = spy
    spy

  should: (matcher, neg=false) =>
    @notOutsideIt 'should'

    @currentExample.result.expectations.push(
      new spectacular.Expectation(
        @currentExample,
        @currentExample.subject,
        matcher,
        neg
      )
    )

  shouldnt: (matcher) => @should matcher, true

  toString: -> '[spectacular Environment]'




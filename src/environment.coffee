
class spectacular.Environment
  constructor: (@Runner, @options) ->
    @rootExampleGroup = new spectacular.ExampleGroup
    @currentExampleGroup = @rootExampleGroup
    @currentExample = null

  run: =>
    @decorate()
    new @Runner(@rootExampleGroup, @options, this).run()

  decorate: =>
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
      skip should shouldnt dependsOn'.split(/\s+/g).forEach (k) =>
      global[k] = ->
        env[k].apply env, arguments


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
        get: block
      }

  describe: (subject, options, block) =>
    [options, block] = [block, options] if typeof options is 'function'
    @notInsideIt 'describe'

    oldGroup = @currentExampleGroup

    @currentExampleGroup = new spectacular.ExampleGroup(
      block, subject, oldGroup, options
    )
    oldGroup.addChild @currentExampleGroup

    @currentExampleGroup.executeBlock()

    @currentExampleGroup = oldGroup

  xdescribe: (subject, block) =>
    @notInsideIt 'xdescribe'

  context: Environment::describe
  xcontext: Environment::xdescribe

  withParameters: (args...) =>
    @notInsideIt 'withParameters'

    @given 'parameters', -> args

  dependsOn: (spec) =>
    @currentExampleGroup.ownDependencies.push spec

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




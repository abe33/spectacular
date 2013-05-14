
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
  currentExampleGroup.ownDependencies.push spec

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







# examples groups

runningSpecs('an error raised in spec file')
.shouldStopWith /message/, ->
  throw new Error 'message'

runningSpecs('an error raised in describe')
.shouldStopWith /message/, ->
  describe 'failing declaration', ->
    throw new Error 'message'

# examples

runningSpecs('pending examples')
.shouldSucceedWith /0 errors, 0 skipped, 2 pending/, ->
  describe 'pending examples', ->
    it -> pending()
    it -> pending()

runningSpecs('excluded examples')
.shouldSucceedWith /2 success, 2 assertion/, ->
  describe 'inclusive examples', ->
    it -> true.should be true
    it -> true.should be true
    except it -> true.should be true

runningSpecs('scoped examples')
.shouldSucceedWith /1 success, 1 assertion/, ->
  describe 'exclusive examples', ->
    it -> true.should be true
    it -> true.should be true
    only it -> true.should be true

runningSpecs('inclusive groups')
.shouldSucceedWith /2 success, 2 assertion/, ->
  describe 'included groups', ->
    it -> true.should be true
    it -> true.should be true

  except describe 'inclusive groups', ->
    it -> true.should be true

runningSpecs('exclusive groups')
.shouldSucceedWith /1 success, 1 assertion/, ->
  describe 'excluded groups', ->
    it -> true.should be true
    it -> true.should be true

  only describe 'exclusive groups', ->
    it -> true.should be true

runningSpecs('skipped examples')
.shouldFailWith /0 errors, 2 skipped/, ->
  describe 'skipped examples', ->
    it -> skip()
    it -> skip()

runningSpecs('failing examples')
.shouldFailWith /2 failures, 0 errors/, ->
  describe 'failing examples', ->
    it -> fail()
    it -> fail()


runningSpecs('long trace, colors, no source and no documentation')
.withOption('longTrace', true)
.withOption('noColors', false)
.withOption('showSource', false)
.withOption('documentation', false)
.shouldFailWith ///
  1\ssuccess
  (.*)
  1\sfailure
  (.*)
  1\serror
  (.*)
  1\sskipped
  (.*)
  1\spending
///, ->
  describe 'failing examples', ->
    it -> true.should be true
    it -> fail()
    it -> throw new Error
    it -> skip()
    it -> pending()

runningSpecs('it without block')
.shouldSucceedWith /0 success, 0 assertions, (.*), 1 pending/, ->
  describe 'it without block', ->
    it 'foo'

runningSpecs('describe without block')
.shouldSucceedWith /0 success, 0 assertions, (.*), 1 pending/, ->
  describe 'foo'

runningSpecs('an async example timing out')
.shouldFailWith /1 failure/, ->
  it (async) ->
    async.rejectAfter 100, 'Timed out'

runningSpecs('an unhandled exception raised in example')
.shouldFailWith /0 assertions, 0 failures, 1 error/, ->
  describe 'failing example', ->
    it -> throw new Error 'message'

runningSpecs('an unhandled exception raised in example with expectations')
.shouldFailWith /1 assertion, 0 failures, 1 error/, ->
  describe 'failing example with expectation', ->
    it 'should have been stopped', ->
      true.should be true
      throw new Error 'message'

# before

runningSpecs('an unhandled exception raised in before')
.shouldFailWith /0 assertions, 0 failures, 1 error/, ->
  describe 'with successful example', ->
    before -> throw new Error 'message'
    it -> true.should be true

runningSpecs('an async before hook timing out')
.shouldFailWith /0 assertions, (.*), 1 error/, ->
  describe 'with successful example', ->
    before (async) ->
      async.rejectAfter 100

    it -> true.should be true

runningSpecs('a rejected async before hook')
.shouldFailWith /0 assertions, (.*), 1 error/, ->
  describe 'with successful example', ->
    before (async) ->
      async.reject new Error 'message'

    it -> true.should be true

# after

runningSpecs('an unhandled exception raised in after')
.shouldFailWith /0 success, 1 assertion, 0 failures, 1 error/, ->
  describe 'with successful example', ->
    after -> throw new Error 'message'
    it -> true.should be true

runningSpecs('an unhandled exception raised in after')
.shouldFailWith /0 success, 1 assertion, 0 failures, 1 error/, ->
  describe 'with failing example', ->
    after -> throw new Error 'message'
    it -> true.should be false

runningSpecs('an async after hook timing out')
.shouldFailWith /1 assertion, (.*), 1 error/, ->
  describe 'with successful example', ->
    after (async) ->
      async.rejectAfter 100

    it -> true.should be true

runningSpecs('a rejected async after hook')
.shouldFailWith /1 assertion, (.*), 1 error/, ->
  describe 'with successful example', ->
    after (async) ->
      async.reject new Error 'message'

    it -> true.should be true

# matchers
runningSpecs('an unhandled exception raised in matcher')
.shouldFailWith /1 assertion, 0 failures, 1 error/, ->
  describe 'failing example', ->
    it -> {}.should throwing

describe 'sequencial assertions', ->
  it 'should succeed', ->
    o = {foo: 10}
    o.foo.should equal 10
    o.foo = "100"
    o.foo.should equal '100'

describe 'snake case syntax', ->
  given 'object', -> method: ->
  before ->
    spy_on @object, 'method'
    @object.method()

  specify 'for haveBeenCalled matcher', ->
    @object.method.should have_been_called

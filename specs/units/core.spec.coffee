# examples groups

runningSpecs('error raised in spec file')
.shouldStopWith /message/, ->
  throw new Error 'message'

runningSpecs('error raised in describe')
.shouldStopWith /message/, ->
  describe 'failing declaration', ->
    throw new Error 'message'

# examples

runningSpecs('pending examples')
.shouldSucceedWith /0 errors, 0 skipped, 2 pending/, ->
  describe 'pending examples', ->
    it -> pending()
    it -> pending()

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

runningSpecs('async example timing out')
.shouldFailWith /1 failure/, ->
  it (async) ->
    async.rejectAfter 100, 'Timed out'

runningSpecs('unhandled exception raised in example')
.shouldFailWith /0 assertions, 0 failures, 1 error/, ->
  describe 'failing example', ->
    it -> throw new Error 'message'

runningSpecs('unhandled exception raised in example with expectations')
.shouldFailWith /1 assertion, 0 failures, 1 error/, ->
  describe 'failing example with expectation', ->
    it 'should have been stopped', ->
      true.should be true
      throw new Error 'message'

# before

runningSpecs('unhandled exception raised in before')
.shouldFailWith /0 assertions, 0 failures, 1 error/, ->
  describe 'with successful example', ->
    before -> throw new Error 'message'
    it -> true.should be true

runningSpecs('async before hook timing out')
.shouldFailWith /0 assertions, (.*), 1 error/, ->
  describe 'with successful example', ->
    before (async) ->
      async.rejectAfter 100

    it -> true.should be true

runningSpecs('async before hook rejected')
.shouldFailWith /0 assertions, (.*), 1 error/, ->
  describe 'with successful example', ->
    before (async) ->
      async.reject new Error 'message'

    it -> true.should be true

# after

runningSpecs('unhandled exception raised in after')
.shouldFailWith /0 success, 1 assertion, 0 failures, 1 error/, ->
  describe 'with successful example', ->
    after -> throw new Error 'message'
    it -> true.should be true

runningSpecs('unhandled exception raised in after')
.shouldFailWith /0 success, 1 assertion, 0 failures, 1 error/, ->
  describe 'with failing example', ->
    after -> throw new Error 'message'
    it -> true.should be false

runningSpecs('async after hook timing out')
.shouldFailWith /1 assertion, (.*), 1 error/, ->
  describe 'with successful example', ->
    after (async) ->
      async.rejectAfter 100

    it -> true.should be true

runningSpecs('async after hook rejected')
.shouldFailWith /1 assertion, (.*), 1 error/, ->
  describe 'with successful example', ->
    after (async) ->
      async.reject new Error 'message'

    it -> true.should be true

# matchers
runningSpecs('unhandled exception raised in matcher')
.shouldFailWith /1 assertion, 0 failures, 1 error/, ->
  describe 'failing example', ->
    it -> {}.should throwing

describe 'sequencial assertions', ->
  it 'should succeed', ->
    o = {foo: 10}
    o.foo.should equal 10
    o.foo = "100"
    o.foo.should equal '100'

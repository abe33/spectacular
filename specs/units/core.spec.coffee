
# examples groups

virtualEnv('error raised in spec file')
.shouldStopWith /message/, ->
  throw new Error 'message'

virtualEnv('error raised in describe')
.shouldStopWith /message/, ->
  describe 'failing declaration', ->
    throw new Error 'message'

# examples

virtualEnv('pending examples')
.shouldSucceedWith /0 errors, 0 skipped, 2 pending/, ->
  describe 'pending examples', ->
    it -> pending()
    it -> pending()

virtualEnv('skipped examples')
.shouldFailWith /0 errors, 2 skipped/, ->
  describe 'skipped examples', ->
    it -> skip()
    it -> skip()

virtualEnv('failing examples')
.shouldFailWith /2 failures, 0 errors/, ->
  describe 'failing examples', ->
    it -> fail()
    it -> fail()

virtualEnv('async example timing out')
.shouldFailWith /1 failure/, ->
  it (async) ->
    async.rejectAfter 100, 'Timed out'

virtualEnv('when unhandled exception is raised in example')
.shouldFailWith /0 assertions, 0 failures, 1 error/, ->
  describe 'failing example', ->
    it -> throw new Error 'message'

virtualEnv('when unhandled exception is raised in example with expectations')
.shouldFailWith /1 assertion, 0 failures, 1 error/, ->
  describe 'failing example with expectation', ->
    it 'should have been stopped', ->
      true.should be true
      throw new Error 'message'

# before

virtualEnv('when unhandled exception is raised in before')
.shouldFailWith /0 assertions, 0 failures, 1 error/, ->
  describe 'with successful example', ->
    before -> throw new Error 'message'
    it -> true.should be true

virtualEnv('when async before hook timing out')
.shouldFailWith /0 assertions, (.*), 1 error/, ->
  describe 'with successful example', ->
    before (async) ->
      async.rejectAfter 100

    it -> true.should be true

virtualEnv('when async before hook rejected')
.shouldFailWith /0 assertions, (.*), 1 error/, ->
  describe 'with successful example', ->
    before (async) ->
      async.reject new Error 'message'

    it -> true.should be true

# after

virtualEnv('when unhandled exception is raised in after')
.shouldFailWith /0 success, 1 assertion, 0 failures, 1 error/, ->
  describe 'with successful example', ->
    after -> throw new Error 'message'
    it -> true.should be true

virtualEnv('when unhandled exception is raised in after')
.shouldFailWith /0 success, 1 assertion, 0 failures, 1 error/, ->
  describe 'with failing example', ->
    after -> throw new Error 'message'
    it -> true.should be false

virtualEnv('when async after hook timing out')
.shouldFailWith /1 assertion, (.*), 1 error/, ->
  describe 'with successful example', ->
    after (async) ->
      async.rejectAfter 100

    it -> true.should be true

virtualEnv('when async after hook rejected')
.shouldFailWith /1 assertion, (.*), 1 error/, ->
  describe 'with successful example', ->
    after (async) ->
      async.reject new Error 'message'

    it -> true.should be true

# matchers
virtualEnv('when unhandled exception is raised in matcher')
.shouldFailWith /1 assertion, 0 failures, 1 error/, ->
  describe 'failing example', ->
    it -> {}.should throwing


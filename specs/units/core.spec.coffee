

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

virtualEnv('xdescribe')
.shouldSucceedWith /0 failures, (.*), 1 pending/, ->
  xdescribe 'pending examples', ->
    it -> fail()

virtualEnv('error raised in spec file')
.shouldStopWith /message/, ->
  throw new Error 'message'

virtualEnv('error raised in describe')
.shouldStopWith /message/, ->
  describe 'failing declaration', ->
    throw new Error 'message'

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


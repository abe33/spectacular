
exports.createEnv = (block, context) ->
  env = spectacular.env.clone()
  env.options.noColors = true
  env.options.showSource = false
  context.results = ''

  spyOn(env, 'load').andCallThrough ->
    promise = new spectacular.Promise.unit()
    promise.then -> do block

  env

exports.createReporter = (env, context, async) ->
  reporter = new spectacular.ConsoleReporter env.options
  context.results = ''
  reporter.on 'message', (e) -> context.results += e.target
  reporter.on 'report', (e) ->
    context.results += e.target
    if context.ended
      if context.rejected?
        async.reject context.rejected
      else
        async.resolve()

    context.ended = true

  env.runner.on 'result', reporter.onResult
  env.runner.on 'end', reporter.onEnd
  reporter

exports.runEnvExpectingNormalTermination = (env, context, async) ->
  oldEnv = spectacular.env
  env.load()
  .then ->
    env.run()
  .then (status) ->
    context.status = status
    oldEnv.load()
    async.resolve() if context.ended
    context.ended = true
  .fail (reason) ->
    context.reason = context.rejected = reason
    oldEnv.load()
    async.reject reason

exports.runEnvExpectingInterruption = (env, context, async) ->
  oldEnv = spectacular.env
  env.load()
  .then ->
    env.run()
  .then (status) =>
    oldEnv.load()
    context.rejected = new Error "run didn't failed"
    async.reject context.rejected if context.ended
    context.ended = true
  .fail (reason) =>
    context.reason = reason
    oldEnv.load()
    async.resolve()

exports.runningSpecs = (desc) ->

  shouldFailWith: (re, block) ->
    describe "running specs with #{desc}", ->
      before (async) ->
        @env = createEnv block, this
        @reporter = createReporter @env, this, async
        runEnvExpectingNormalTermination @env, this, async

      it 'should fail, status', -> @status.should be 1
      it 'should fail, results', -> @results.should match re

  shouldSucceedWith: (re, block) ->
    describe "running specs with #{desc}", ->
      before (async) ->
        @env = createEnv block, this
        @reporter = createReporter @env, this, async
        runEnvExpectingNormalTermination @env, this, async

      it 'should succeed, status', -> @status.should be 0
      it 'should succeed, results', -> @results.should match re

  shouldStopWith: (re, block) ->
    describe "running specs with #{desc}", ->
      before (async) ->
        @env = createEnv block, this
        @reporter = createReporter @env, this, async
        runEnvExpectingInterruption @env, this, async

      it 'should stop, error message', ->
        @reason.message.should match re

exports.environmentMethod = (method) ->
  cannotBeCalledInsideIt: ->
    runningSpecs('called inside it')
    .shouldFailWith /called inside a it block/, ->
      describe 'foo', ->
        it ->
          m = spectacular.global[method]
          m()

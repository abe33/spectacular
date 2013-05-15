
exports.TEST_PATTERN = '\\[[^\\]]+\\]'
exports.EXAMPLE_PATTERN = '\\[Example\\([^\\]]+\\)\\]'
exports.EXAMPLE_GROUP_PATTERN = '\\[ExampleGroup\\([^\\]]+\\)\\]'

exports.virtualEnv = (desc) ->
  setupEnv = (context, async, block) ->

  shouldFailWith: (re, block) ->
    describe desc, ->
      before (async) ->
        oldEnv = spectacular.env
        context = this

        @env = spectacular.env.clone()
        @env.options.noColors = true
        spyOn(@env.runner, 'loadSpecs').andCallFake -> do block
        spyOn(@env.runner, 'printExampleResult').andCallFake ->
        spyOn(@env.runner, 'printResults').andCallFake ->
          context.results = @formatCounters()

        @env.run()
        .then (status) =>
          @status = status
          oldEnv.load()
          async.resolve()
        .fail (reason) =>
          @reason = reason
          oldEnv.load()
          async.reject new Error "run failed"

      it "status", -> @status.should be 1
      it 'results', -> @results.should match re

  runShouldFailWith: (re, block) ->
    describe desc, ->
      before (async) ->
        oldEnv = spectacular.env
        @env = spectacular.env.clone()
        spyOn(@env.runner, 'loadSpecs').andCallFake -> do block

        @env.run()
        .then (status) =>
          oldEnv.load()
          async.reject new Error "run didn't failed"
        .fail (reason) =>
          @reason = reason
          oldEnv.load()
          async.resolve()

      it 'error message', ->
        @reason.message.should match re





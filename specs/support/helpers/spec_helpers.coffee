
exports.TEST_PATTERN = '\\[[^\\]]+\\]'
exports.EXAMPLE_PATTERN = '\\[Example\\([^\\]]+\\)\\]'
exports.EXAMPLE_GROUP_PATTERN = '\\[ExampleGroup\\([^\\]]+\\)\\]'

exports.virtualEnv = (desc) ->
  setupEnv = (context, async, block) ->

  shouldFailWith: (re, block) ->
    describe desc, ->
      before (async) ->
        oldEnv = spectacular.env
        oldLoadSpecs = spectacular.env.Runner::loadSpecs
        oldPrintResults = spectacular.env.Runner::printResults
        oldPrintExampleResult = spectacular.env.Runner::printExampleResult
        context = this

        @env = spectacular.env.clone()
        @env.options.noColors = true
        @env.Runner::loadSpecs = -> do block
        @env.Runner::printExampleResult = ->
        @env.Runner::printResults = ->
          context.results = @formatCounters()

        @env.run()
        .then (status) =>
          @status = status
          oldEnv.Runner::loadSpecs = oldLoadSpecs
          oldEnv.Runner::printResults = oldPrintResults
          oldEnv.Runner::printExampleResult = oldPrintExampleResult
          oldEnv.load()

          async.resolve()

        .fail (reason) =>
          @reason = reason
          oldEnv.Runner::loadSpecs = oldLoadSpecs
          oldEnv.Runner::printResults = oldPrintResults
          oldEnv.Runner::printExampleResult = oldPrintExampleResult
          oldEnv.load()

          async.reject new Error "run failed"

      it "status", -> @status.should be 1
      it 'results', -> @results.should match re

  runShouldFailWith: (re, block) ->
    describe desc, ->
      before (async) ->
        oldEnv = spectacular.env
        oldLoadSpecs = spectacular.env.Runner::loadSpecs
        @env = spectacular.env.clone()
        @env.Runner::loadSpecs = -> do block
        @env.run()
        .then (status) =>
          oldEnv.Runner::loadSpecs = oldLoadSpecs
          oldEnv.load()

          async.reject new Error "run didn't failed"

        .fail (reason) =>
          @reason = reason
          oldEnv.Runner::loadSpecs = oldLoadSpecs
          oldEnv.load()

          async.resolve()

      it 'error message', ->
        @reason.message.should match re

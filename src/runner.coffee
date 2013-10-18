
class spectacular.Random
  constructor: (@seed) ->
  get: ->
    @seed = (@seed * 9301 + 49297) % 233280
    @seed / 233280.0

class spectacular.RunnerResults
  constructor: (@runner) ->
    @errors = []
    @failures = []
    @skipped = []
    @pending = []
    @results = []
    @examples = []
    {@loadStartedAt, @loadEndedAt} = @runner
    @specsStartedAt = null
    @specsEndedAt = null

  hasFailures: -> @examples.some (e) ->
    e.result.state in ['skipped', 'failure', 'errored']

class spectacular.Runner

  @include spectacular.EventDispatcher

  constructor: (@root, @options, @env) ->
    @results = []
    @examples = []
    @stack = []

    seed = if @options.seed?
      @options.seed
    else
      Math.round(Math.random() * 99999999)

    @options.seed = seed

    @random = new spectacular.Random seed
    @randomSort = => Math.round 1 - @random.get() * 2

  run: () =>
    results = new spectacular.RunnerResults this
    promise = spectacular.Promise.unit(results)
    .then (results) ->
      results.specsStartedAt = new Date()
      results
    .then(@registerSpecs)
    .then(@executeSpecs)
    .then (results) ->
      results.specsEndedAt = new Date()
      results
    .then(@notifyEnd)
    .then (results) ->
      if results.hasFailures() then 1 else 0

  findSpecFileInStack: (stack) ->
    for p in @options.paths or []
      for l,i in stack
        return i if l.indexOf(p) isnt -1
    -1

  registerSpecs: (results) =>
    set = @root.children
    set = set.sort(@randomSort) if @options.random
    for example in set
      @register example, @root.hasExclusiveExamples()

    @dispatch new spectacular.Event 'start', this
    results

  register: (child, exclusiveOnly=false) ->
    if child.children?
      if exclusiveOnly
        if child.hasExclusiveExamplesWithDependencies()
          for c in child.allExclusiveExamplesWithDependecies
            @registerDependencies c, exclusiveOnly

        set = child.allExclusiveExamples
        set = set.sort(@randomSort) if @options.random
        @register c, exclusiveOnly for c in set

      else
        if child.hasExamplesWithDependencies()
          for c in child.allExamplesWithDependecies
            @registerDependencies c, exclusiveOnly

        set = child.allExamples
        set = set.sort(@randomSort) if @options.random
        @register c, exclusiveOnly for c in set

    else
      return if exclusiveOnly and not child.exclusive
      if child.hasDependencies()
        @registerDependencies child, exclusiveOnly

      @insert child, exclusiveOnly

  registerDependencies: (child) ->
    for dep in child.dependencies
      dependency = @root.identifiedExamplesMap[dep]
      if dependency?
        @checkDependency child, dependency
        @register dependency

  insert: (example) ->
    @handleDependencies example
    @examples.push example unless example in @examples
    @stack.push example unless example in @stack

  handleDependencies: (example) ->
    return if example in @stack
    dependencies = []
    cascading = null
    dependenciesSucceed = null
    cascadingSucceed = null

    if example.dependencies.length > 0
      for dep in example.dependencies
        dependency = @root.identifiedExamplesMap[dep]
        if dependency?
          dependencies.push dependency
        else
          msg = "Warning: unmet dependency #{dep} for example #{example}"
          msg = msg.yellow if @options.colors
          @dispatch new spectacular.Event 'message', msg

      dependenciesSucceed = -> dependencies.every (e) -> e.succeed

    if example.cascading?
      @register s for s in example.cascading.examples
      cascadingSucceed = -> example.cascading.examplesSuceed

    if dependenciesSucceed?
      if cascadingSucceed?
        example.dependenciesMet = ->
          dependenciesSucceed() and cascadingSucceed()
      else
        example.dependenciesMet = dependenciesSucceed
    else if cascadingSucceed?
      example.dependenciesMet = cascadingSucceed

  checkDependency: (example, dependency) ->
    if dependency in example.ancestors
      throw new Error "#{example} can't depends on ancestor #{dependency}"

    @checkCircularity example, dependency

  checkCircularity: (example, dependency) ->
    currentParents = example.identifiedAncestors.map (a) -> a.options.id
    depParents = dependency.identifiedAncestors.map((a) -> a.options.id).concat(dependency.options.id)

    for id in currentParents
      if id in depParents
        throw new Error(
          "circular dependencies between #{example} and #{dependency}"
        )

    if dependency.dependencies.length > 0
      for dep in dependency.dependencies
        dependency = @root.identifiedExamplesMap[dep]
        @checkCircularity example, dependency if dependency?

    return

  executeSpecs: (results) =>
    promise = new spectacular.Promise
    @nextExample promise, results
    promise

  nextExample: (defer, results) =>
    spectacular.nextTick =>
      if @stack.length is 0
        defer.resolve(results)
      else
        nextExample = @stack.shift()

        @env.currentExample = nextExample
        nextExample.run()
        .then =>
          @handleResult nextExample, results
          @nextExample defer, results
        .fail (reason) =>
          @handleResult nextExample, results
          @nextExample defer, results

  handleResult: (example, results) ->
    results.results.push example.result
    results.examples.push example

    switch example.result.state
      when 'pending' then results.pending.push example
      when 'skipped' then results.skipped.push example
      when 'errored' then results.errors.push example
      when 'failure' then results.failures.push example

    @dispatch new spectacular.Event 'result', example
    @env.currentExample = null

  notifyEnd: (results) =>
    @dispatch new spectacular.Event 'end', results
    results

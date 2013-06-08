
nextTick = process?.setImmediate or process?.nextTick or (callback) ->
  setTimeout callback, 0

class spectacular.Runner
  @include spectacular.EventDispatcher

  constructor: (@root, @options, @env) ->
    @results = []
    @examples = []
    @stack = []

  run: () =>
    promise = spectacular.Promise.unit()
    .then =>
      @specsStartedAt = new Date()
    .then(@registerSpecs)
    .then(@executeSpecs)
    .then =>
      @specsEndedAt = new Date()
    .then(@notifyEnd)
    .then =>
      if @hasFailures() then 1 else 0

  findSpecFileInStack: (stack) ->
    for p in @paths
      for l,i in stack
        return i if l.indexOf(p) isnt -1
    -1

  registerSpecs: =>
    for example in @root.children
      @register example, @root.hasExclusiveExamples()

  register: (child, exclusiveOnly=false) ->
    if child.children?
      if exclusiveOnly
        if child.hasExclusiveExamplesWithDependencies()
          for c in child.allExclusiveExamplesWithDependecies
            @registerDependencies c, exclusiveOnly

        @register c, exclusiveOnly for c in child.allExclusiveExamples

      else
        if child.hasExamplesWithDependencies()
          for c in child.allExamplesWithDependecies
            @registerDependencies c, exclusiveOnly

        @register c, exclusiveOnly for c in child.allExamples

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
          throw new Error "unmet dependency #{dep} for example #{example}"

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

  executeSpecs: =>
    promise = new spectacular.Promise
    @nextExample promise
    promise

  nextExample: (defer) =>
    nextTick =>
      if @stack.length is 0
        defer.resolve()
      else
        nextExample = @stack.shift()

        @env.currentExample = nextExample
        nextExample.run()
        .then =>
          @handleResult nextExample
          @nextExample defer
        .fail (reason) =>
          @handleResult nextExample
          @nextExample defer

  handleResult: (example) ->
    @dispatch new spectacular.Event 'result', example
    @env.currentExample = null

  notifyEnd: =>
    @dispatch new spectacular.Event 'end', this

  hasFailures: -> @examples.some (e) ->
    e.result.state in ['skipped', 'failure', 'errored']

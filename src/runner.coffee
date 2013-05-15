Q = require 'q'
fs = require 'fs'
glob = require 'glob'
path = require 'path'
util = require 'util'
require 'colors'

class Runner
  constructor: (@root, @options, @env) ->
    @results = []
    @examples = []
    @stack = []

  run: =>
    promise = @globPaths()
    .then (paths) =>
      @loadStartedAt = new Date()
      paths
    .then(@loadSpecs)
    .then =>
      @loadEndedAt = new Date()
      @specsStartedAt = new Date()
    .then(@registerSpecs)
    .then(@executeSpecs)
    .then =>
      @specsEndedAt = new Date()
    .then(@printResults)
    .then =>
      if @hasFailures() then 1 else 0

  globPaths: =>
    Q.all(@glob p for p in @options.globs).then (results) =>
      paths = []
      results.forEach (a) -> paths = paths.concat a
      paths

  glob: (path) ->
    defer = Q.defer()
    glob path, (err, res) ->
      return defer.reject err if err
      defer.resolve res

    defer.promise

  loadSpecs: (paths) =>
    console.log "Load specs: #{paths}" if @options.verbose
    console.log ''
    require path.resolve('.', p) for p in paths

  registerSpecs: =>
    @register example for example in @root.allExamples

  register: (example) =>
    if example.dependencies.length > 0
      @handleDependencies example

    @stack.push example unless @stack.indexOf(example) isnt -1

  handleDependencies: (example) ->
    deps = []
    for dep in example.dependencies
      dependency = @root.identifiedExamplesMap[dep]
      if dependency?
        @checkDependency example, dependency
        deps.push dependency
        if dependency.children?
          @register s for s in dependency.allExamples
        else
          @register dependency
      else
        throw new Error "unmet dependencicy #{dep} for example #{example}"

    example.dependenciesMet = -> deps.every (e) -> e.succeed

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

  executeSpecs: =>
    defer = Q.defer()
    @nextExample defer
    defer.promise

  nextExample: (defer) =>
    if @stack.length is 0
      defer.resolve()
    else
      nextExample = @stack.shift()

      @env.currentExample = nextExample
      nextExample.run()
      .then =>
        @registerResults nextExample
        @nextExample defer
      .fail (reason) =>
        @registerResults nextExample
        @nextExample defer

  registerResults: (example) ->
    @env.currentExample = null
    @printExampleResult example
    @examples.push example
    @results.push example.result


  hasFailures: ->
    @results.some (result) -> result.state in ['failure', 'skipped']

  indent: (string, ind=4) ->
    s = ''
    s = "#{s} " for i in [0..ind-1]

    "#{s}#{string.replace /\n/g, "\n#{s}"}"

  printExampleResult: (example) ->
    if @options.noColors
      switch example.result.state
        when 'pending' then util.print '*'
        when 'skipped' then util.print 'x'
        when 'failure' then util.print 'F'
        when 'success' then util.print '.'

    else
      switch example.result.state
        when 'pending' then util.print '*'.yellow
        when 'skipped' then util.print 'x'.magenta
        when 'failure' then util.print 'F'.red
        when 'success' then util.print '.'.green

  printStack: (e) ->
    stactString = e.stack.replace(/^.*\n/, '')
    stack = stactString.split('\n')
    @printErrorInFile stack[0] if @options.showSource

    if @options.longTrace
      res = "\n\n#{stactString}"
    else
      res = "\n#{
        stack[0..5]
        .concat(
          "    ...\n\n    use --long-trace option to view the #{
            stack.length - 6
          } remaining lines"
        ).join('\n')
      }"

    res = res.grey unless @options.noColors
    console.log res

  printErrorInFile: (line) ->
    re = /\((.*):(.*):(.*)\)/
    [match, file, line, column] = re.exec line

    console.log ''
    console.log @getLines(file, parseInt(line), parseInt(column))

  getLines: (file, line, column) ->
    fileContent = fs.readFileSync(file).toString()

    if @options.coffee and file.indexOf('.coffee') isnt -1
      {compile} = require 'coffee-script'
      fileContent = compile fileContent, bare: true

    fileContent = fileContent.split('\n').map (l,i) =>
      "    #{@padRight i + 1} | #{l}"

    @insertColumnLine fileContent, line, column

    startLine = Math.max(1, line - 3) - 1
    endLine = Math.min(fileContent.length, line + 2) - 1

    lines = fileContent[startLine..endLine].join('\n')
    lines = lines.grey unless @options.noColors
    lines

  insertColumnLine: (content, line, column) ->
    if line is content.length
      content.push line
    else
      content.splice line, 0, "         |#{@padRight('^', column-1)}"

  padRight: (string, pad=4) ->
    string = string.toString()
    string = " #{string}" while string.length < pad
    string

  printFailure: (message) ->
    badge = ' FAIL '
    console.log if @options.noColors
      "#{badge} #{message}"
    else
      "#{badge.inverse.bold} #{message}".red

  printMessage: (message) ->
    console.log "\n#{@indent message}"

  printResults: =>
    console.log '\n'
    if @hasFailures()
      for result in @results
        if result.state is 'failure'
          if result.expectations.length > 0
            for expectation in result.expectations
              unless expectation.success
                @printFailure expectation.description
                @printMessage expectation.message
                @printStack expectation.trace if @options.trace
                console.log '\n'
          else
            @printFailure result.example.description
            @printMessage result.example.examplePromise.reason.message
            @printStack result.example.examplePromise.reason if @options.trace
            console.log '\n'

    console.log @formatCounters()

  formatCounters: ->
    success = @examples.filter((e)-> e.result.state is 'success').length
    failures = @examples.filter((e)-> e.result.state is 'failure').length
    skipped = @examples.filter((e)-> e.result.state is 'skipped').length
    pending = @examples.filter((e)-> e.result.state is 'pending').length
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0
    loadDuration = @formatDuration @loadStartedAt, @loadEndedAt
    specsDuration = @formatDuration @specsStartedAt, @specsEndedAt

    """
    Specs loaded in #{loadDuration}
    Finished in #{specsDuration}
    #{@formatResults success, failures, skipped, pending, assertions}

    """

  formatResults: (s, f, sk, p, a) ->
    "#{@formatCount s, 'success', 'success', @toggle f, 'green'},
    #{@formatCount a, 'assertion', 'assertions', @toggle f, 'green'},
    #{@formatCount f, 'failure', 'failures', @toggle f, 'green', 'red'},
    #{@formatCount sk, 'skipped', 'skipped', @toggle sk, 'green', 'magenta'},
    #{@formatCount p, 'pending', 'pending', @toggle p, 'green', 'yellow'}
    ".replace /\s+/g, ' '

  formatDuration: (start, end) ->
    duration = (end.getMilliseconds() - start.getMilliseconds()) / 1000
    duration = "#{Math.max 0, duration}s"
    duration = duration.yellow unless @options.noColors
    duration

  formatCount: (value, singular, plural, color) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s = s[color] if color? and not @options.noColors
    s

  toggle: (value, c1, c2) ->
    if value is 0 then c1 else c2


module.exports = Runner

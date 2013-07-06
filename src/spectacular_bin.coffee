fs = require 'fs'
vm = require 'vm'
path = require 'path'
exists = fs.exists or path.exists
require 'colors'

SPECTACULAR = path.resolve __dirname, '..'
ROOT = path.resolve '.'

[node, binPath, args...] = process.argv

existsSync = fs.existsSync or path.existsSync

SPECTACULAR_CONFIG = path.resolve ROOT, '.spectacular'

args.push '-h' if args.length is 0

if existsSync SPECTACULAR_CONFIG
  args = fs.readFileSync(SPECTACULAR_CONFIG).toString()
  .replace(/^\s+|\s+$/g, '')
  .split(/\s+/g)
  .concat(args)

options =
  coffee: false
  verbose: false
  profile: false
  trace: true
  longTrace: false
  showSource: true
  documentation: false
  matchersRoot: './specs/support/matchers'
  helpersRoot: './specs/support/helpers'
  fixturesRoot: './specs/support/fixtures'
  noMatchers: false
  noHelpers: false
  colors: true
  cli: true
  server: false
  phantomjs: false
  random: true
  seed: null
  globs: []
  sources: []

while args.length
  option = args.shift()

  switch option
    when '--coffee', '-c'
      options.coffee = true
      require 'coffee-script'
    when '--no-matchers' then options.noMatchers = true
    when '--no-helpers' then options.noHelpers = true
    when '--colors' then options.colors = true
    when '--no-colors' then options.colors = false
    when '--matchers', '-m' then options.matchersRoot = args.shift()
    when '--helpers' then options.helpersRoot = args.shift()
    when '--fixtures' then options.fixturesRoot = args.shift()
    when '--trace', '-t' then options.trace = true
    when '--no-trace' then options.trace = false
    when '--long-trace' then options.longTrace = true
    when '--documentation', '-d' then options.documentation = true
    when '--verbose', '-v' then options.verbose = true
    when '--profile', '-p' then options.profile = true
    when '--random' then options.random = true
    when '--no-random' then options.random = false
    when '--seed' then options.seed = parseInt args.shift()
    when '--server', '-s'
      options.cli = false
      options.server = true
    when '--source' then options.sources.push args.shift()
    when '--version'
      options.cli = false
      console.log require("#{ROOT}/package.json").version
    when '-h', '--help'
      options.cli = false
      console.log '''

# Spectacular Help

  Usage:

    spectacular [options] [globs...]

  Options:

    -c, --coffee         Add support for CoffeeScript files.
    -d, --documentation  Enable the documentation format in the output.
    -h, --help           Display this message.
    -m, --matchers PATH  Specify the path where project matchers can be found.
    -p, --profile        Add a report with the 10 slowest examples.
    -s, --server         Starts a server.
    -t, --trace          Enable stack trace report for failures.
    -v, --verbose        Enable verbose output.
    --fixtures PATH      Specify the path where project fixtures can be found.
    --helpers PATH       Specify the path where project helpers can be found.
    --long-trace         Display the full stack trace.
    --colors             Enable coloring from the output.
    --no-colors          Disable coloring from the output.
    --seed               Set the seed of the test ranomizer.
    --random             Enable the randomness of test execution
    --no-random          Disable the randomness of test execution.
    --no-helpers         Disable the loading of project helpers.
    --no-matchers        Disable the loading of project matchers.
    --no-trace           Remove stack trace from failures reports.
    --phantomjs          Starts a server and run the test on phantomjs.
    --source GLOB        Source files for the server.
    --version            Display the Spectacular version.

'''

    when '--phantomjs'
      options.cli = false
      options.server = true
      options.phantomjs = true
    else options.globs.push option

#### Lookup for the spectacular lib.
#
# When a project owns a version of Spectacular, that version is used
# instead of the global one.
exists path.resolve(ROOT, 'node_modules/spectacular'), (exist) ->
  if exist
    spectacularPath = path.resolve(ROOT, 'node_modules/spectacular')
  else
    spectacularPath = SPECTACULAR

  if options.cli
    spectacular = require("#{spectacularPath}/lib/cli")
  else if options.server
    spectacular = require("#{spectacularPath}/lib/server")

  if spectacular?
    spectacular.run(options).then (status) -> process.exit status

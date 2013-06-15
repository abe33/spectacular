fs = require 'fs'
vm = require 'vm'
path = require 'path'
exists = fs.exists or path.exists

SPECTACULAR = path.resolve __dirname, '..'
ROOT = path.resolve '.'

[node, binPath, args...] = process.argv

existsSync = fs.existsSync or path.existsSync

SPECTACULAR_CONFIG = path.resolve ROOT, '.spectacular'

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
  noColors: false
  server: false
  phantomjs: false
  globs: []

while args.length
  option = args.shift()

  switch option
    when '--coffee', '-c'
      options.coffee = true
      require 'coffee-script'
    when '--no-matchers' then options.noMatchers = true
    when '--no-helpers' then options.noHelpers = true
    when '--no-colors' then options.noColors = true
    when '--matchers', '-m' then options.matchersRoot = args.shift()
    when '--helpers' then options.helpersRoot = args.shift()
    when '--fixtures' then options.fixturesRoot = args.shift()
    when '--trace', '-t' then options.trace = true
    when '--no-trace' then options.trace = false
    when '--long-trace' then options.longTrace = true
    when '--documentation', '-d' then options.documentation = true
    when '--verbose', '-v' then options.verbose = true
    when '--profile', '-p' then options.profile = true
    when '--server', '-s' then options.server = true
    when '--phantomjs'
      options.server = true
      options.phantomjs = true
    else options.globs.push option

console.log 'options:', options if options.verbose

#### Lookup for the spectacular lib.
#
# When a project owns a version of Spectacular, that version is used
# instead of the global one.
exists path.resolve(ROOT, 'node_modules/spectacular'), (exist) ->
  if exist
    spectacular = require path.resolve(ROOT,
                                       'node_modules/spectacular/lib/index')
  else
    spectacular = require path.resolve(SPECTACULAR,
                                       'lib/index')

  spectacular.run(options).then (status) -> process.exit status

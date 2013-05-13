fs = require 'fs'
vm = require 'vm'
path = require 'path'
exists = fs.exists or path.exists

SPECTACULAR = path.resolve __dirname, '..'
ROOT = path.resolve '.'

[node, binPath, args...] = process.argv

options =
  coffee: false
  verbose: false
  trace: false
  matchersRoot: './specs/support/matchers'
  noMatchers: false
  globs: []

while args.length
  option = args.shift()

  switch option
    when '--coffee', '-c'
      options.coffee = true
      require 'coffee-script'
    when '--no-matchers' then options.noMatchers = true
    when '--matchers', '-m' then options.matchersRoot = options.shift()
    when '--trace', '-t' then options.trace = true
    when '--verbose', '-v' then options.verbose = true
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

  spectacular.run(options).then (status) ->
    process.exit status

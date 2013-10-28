require 'colors'

fs = require 'fs'
glob = require 'glob'
jade = require 'jade'
path = require 'path'
{exec, spawn} = require 'child_process'
{print} = require 'util'

Q = require 'q'

SPECTACULAR_ROOT = path.resolve __dirname

version = require('./package.json').version

badge = (str) -> " #{str.toUpperCase()} ".inverse

done = (str) -> '\n  ' + badge('done').green + ' ' + str.yellow.bold
fail = (str) -> '\n  ' + badge('error').red + ' ' + str

exeHandle = (p,f) ->
  [p,f] = [f,p] if typeof p is 'function'
  (err, stdout, stderr) ->
    return p.reject stdout + err + stderr if err?
    print stdout if stdout? and stdout.length > 0
    f stdout

run = (command) -> ->
  console.log "  run #{command.cyan}"
  defer = Q.defer()
  exec command, exeHandle defer, -> defer.resolve()
  defer.promise

globPath = (p) ->
  defer = Q.defer()
  glob p, (err, res) ->
    return defer.reject err if err
    defer.resolve res

  defer.promise

globPaths= (globs) ->
  Q.all(globPath p for p in globs).then (results) =>
    paths = []
    results.forEach (a) -> paths = paths.concat a
    paths

compileTemplates = ->
  globPaths([path.resolve SPECTACULAR_ROOT, 'templates/formatters/*.jade'])
  .then (tpls) ->
    res = ''

    for p in tpls
      n = p.split('/')
      n = n[n.length - 1]
      n = n.split('.')[0]

      tpl = jade.compile(fs.readFileSync(p), client: true, compileDebug: false).toString()
      res += "\nspectacular.templates['#{n}'] = #{tpl}\n"

    res

compileSpectacularNode = ->
  options = [
    "--compile"
    "--bare"
    "--output"
    "lib/"
    "--join"
    "lib/spectacular.js"
    "src/extensions.coffee"
    "src/bootstrap.coffee"
    "src/utils.coffee"
    "src/errors.coffee"
    "src/mixins.coffee"
    "src/factories.coffee"
    "src/promises.coffee"
    "src/examples.coffee"
    "src/dom.coffee"
    "src/runner.coffee"
    "src/environment.coffee"
    "src/matchers.coffee"
    "src/formatters.coffee"
    "src/formatters/console.coffee"
    "src/formatters/console/*.coffee"
    "src/console_reporter.coffee"
  ]
  run("./node_modules/.bin/coffee #{options.join ' '}")()

compileBrowserPart = ->
  options = [
    "--compile"
    "--bare"
    "--output"
    "lib/"
    "--join"
    "lib/browser_reporter.js"
    "src/formatters/browser.coffee"
    "src/formatters/browser/*.coffee"
    "src/browser_reporter.coffee"
  ]
  run("./node_modules/.bin/coffee #{options.join ' '}")()

compileNode = ->
  compileSpectacularNode()
  .then(compileBrowserPart)
  .then ->
    options = [
      "--compile"
      "--bare"
      "--output"
      "lib/"
      "src/cli.coffee"
      "src/server.coffee"
      "src/spectacular_bin.coffee"
      "src/spectacular_phantomjs.coffee"
      "src/spectacular_slimerjs.coffee"
    ]

    run("./node_modules/.bin/coffee #{options.join ' '}")()
  .then(run "echo '#!/usr/bin/env node' > bin/spectacular")
  .then(run "cat lib/spectacular_bin.js >> bin/spectacular")
  .then(run "chmod +x bin/spectacular")
  .then(run "rm lib/spectacular_bin.js")

compileTests = ->
  options = [
    "--compile"
    "--output"
    "docs/js/"
    "--join"
    "docs/js/specs.js"
    "specs/support/matchers/*.coffee"
    "specs/support/helpers/*.coffee"
    "specs/units/*.coffee"
  ]

  run("./node_modules/.bin/coffee #{options.join ' '}")()
  .then(run 'cp -r ./specs/support/fixtures ./docs/js')

compileBrowser = ->
  options = [
    "--compile"
    "--output"
    "docs/build/js"
    "--join"
    "docs/build/js/spectacular.js"
    "src/extensions.coffee"
    "src/bootstrap.coffee"
    "src/utils.coffee"
    "src/errors.coffee"
    "src/mixins.coffee"
    "src/factories.coffee"
    "src/promises.coffee"
    "src/examples.coffee"
    "src/dom.coffee"
    "src/runner.coffee"
    "src/environment.coffee"
    "src/matchers.coffee"
    "src/formatters.coffee"
    "src/formatters/console.coffee"
    "src/formatters/console/*.coffee"
    "src/formatters/browser.coffee"
    "src/formatters/browser/*.coffee"
    "src/console_reporter.coffee"
    "src/browser_reporter.coffee"
  ]

  run("./node_modules/.bin/coffee #{options.join ' '}")()
  .then ->
    compileTemplates()
  .then (res) ->
    fs.writeFileSync 'docs/build/js/templates.js', res
  .then ->
    opts = '-o docs/build/js/spectacular.min.js docs/build/js/spectacular.js'
    run("./node_modules/.bin/uglifyjs #{opts}")()
  .then ->
    opts = '-o docs/build/js/templates.min.js docs/build/js/templates.js'
    run("./node_modules/.bin/uglifyjs #{opts}")()
  .then(compileTests)
  .then(run "./node_modules/.bin/stylus css/spectacular.styl")
  .then(run "cp css/spectacular.css docs/build/css/spectacular.css")
  .then(run "cp vendor/source-map.js docs/build/vendor/source-map.js")
  .then(run "cp vendor/source-map.min.js docs/build/vendor/source-map.min.js")
  .then(run "cp vendor/snap.js docs/build/vendor/snap.js")
  .then(run "cp vendor/jade.js docs/build/vendor/jade.js")
  .then(run "cd ./docs/build; zip -r ../spectacular-#{version}.zip *")
  .then(run """echo "---
title: ChangeLog
date: #{new Date()}
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----" > docs/changelog.md""")
  .then(run 'cat CHANGELOG.md | sed s/^#/##/ >> docs/changelog.md')

task 'compile', 'Compiles the project sources', ->
  compileNode()
  .then ->
    console.log done 'Nodejs files compiled'
  .fail (err) ->
    console.log fail err

task 'build', 'Build the project for node and the browser with docs', ->
  compileNode()
  .then ->
    console.log done 'Nodejs files compiled'
  .then(compileBrowser)
  .then ->
    console.log done 'Browser files compiled and documentation ready for build'
  .fail (err) ->
    console.log fail err

task 'server', 'Compiles and run the server', ->
  compileNode()
  .then ->
    exe = spawn './bin/spectacular', ['server', '--profile', '--coffee', 'specs/units/**/*.spec.*']
    exe.stdout.on 'data', (data) -> print data.toString()
    exe.stderr.on 'data', (data) -> print data.toString()
    exe.on 'exit', (status) -> process.exit status
  .fail (err) ->
    console.log fail err

task 'phantomjs', 'Run specs on phantomjs', ->
  compileNode()
  .then(run './bin/spectacular phantomjs --coffee --profile specs/units/**/*.spec.*')
  .fail (err) ->
    console.log fail err

task 'slimerjs', 'Run specs on slimerjs', ->
  compileNode()
  .then(run './bin/spectacular slimerjs --coffee --profile specs/units/**/*.spec.*')
  .fail (err) ->
    console.log fail err

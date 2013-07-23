require 'colors'

fs = require 'fs'
path = require 'path'
{exec, spawn} = require 'child_process'
{print} = require 'util'

Q = require 'q'

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
    "src/mixins.coffee"
    "src/factories.coffee"
    "src/promises.coffee"
    "src/examples.coffee"
    "src/dom.coffee"
    "src/runner.coffee"
    "src/environment.coffee"
    "src/matchers.coffee"
    "src/console_reporter.coffee"
  ]
  run("./node_modules/.bin/coffee #{options.join ' '}")()

compileNode = ->
  compileSpectacularNode()
  .then ->
    options = [
      "--compile"
      "--bare"
      "--output"
      "lib/"
      "src/cli.coffee"
      "src/server.coffee"
      "src/spectacular_bin.coffee"
      "src/browser_reporter.coffee"
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
    "src/mixins.coffee"
    "src/factories.coffee"
    "src/promises.coffee"
    "src/examples.coffee"
    "src/dom.coffee"
    "src/runner.coffee"
    "src/environment.coffee"
    "src/matchers.coffee"
    "src/console_reporter.coffee"
    "src/browser_reporter.coffee"
  ]

  run("./node_modules/.bin/coffee #{options.join ' '}")()
  .then ->
    opts = '-o docs/build/js/spectacular.min.js docs/build/js/spectacular.js'
    run("./node_modules/.bin/uglifyjs #{opts}")()
  .then(compileTests)
  .then(run "./node_modules/.bin/stylus css/spectacular.styl")
  .then(run "cp css/spectacular.css docs/build/css/spectacular.css")
  .then(run "cd ./docs/build; zip -r ../spectacular-#{version}.zip *")
  .then(run """echo "---
title: ChangeLog
date: #{new Date()}
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----" > docs/changelog.md""")
  .then(run 'cat CHANGELOG.md >> docs/changelog.md')

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
    console.log done 'Browser files compiled'
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

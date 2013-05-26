{exec, spawn} = require 'child_process'
{print} = require 'util'

exeHandle = (f) ->
  (err, stdout, stderr) ->
    return print stderr if err?
    print stdout if stdout? and stdout.length > 0
    f stdout

task 'compile', 'Compiles the project sources', ->
  exec './node_modules/.bin/coffee --compile --bare --output lib/ --join lib/spectacular.js src/extensions.coffee  src/bootstrap.coffee src/utils.coffee src/factories.coffee src/mixins.coffee src/promises.coffee src/examples.coffee src/runner.coffee src/environment.coffee src/console_reporter.coffee', exeHandle ->

    exec './node_modules/.bin/coffee --compile --bare --output lib/ src/cli.coffee src/server.coffee src/index.coffee src/matchers.coffee src/spectacular_bin.coffee src/browser_reporter.coffee src/spectacular_phantomjs.coffee', exeHandle ->

      exec "echo '#!/usr/bin/env node' > bin/spectacular", exeHandle ->
        exec "cat lib/spectacular_bin.js >> bin/spectacular",exeHandle ->
          exec "chmod +x bin/spectacular", exeHandle ->
            exec "rm lib/spectacular_bin.js", exeHandle ->
              console.log 'files compiled'

task 'server', 'Compiles and run the server', ->
  exec 'cake compile', exeHandle ->
    exe = spawn './bin/spectacular', ['--server', '--coffee', 'specs/units/**/*.spec.*']
    exe.stdout.on 'data', (data) -> print data.toString()
    exe.stderr.on 'data', (data) -> print data.toString()
    exe.on 'exit', (status) -> process.exit status

task 'phantomjs', 'Run specs on phantomjs', ->
  exec 'cake compile', exeHandle ->
    exe = spawn './bin/spectacular', ['--server', '--coffee', 'specs/units/**/*.spec.*']
    exe.stderr.on 'data', (data) -> print data.toString()
    exe.stdout.on 'data', (data) ->
      print data.toString()

      if data.toString().indexOf('Server listening on port 5000') isnt -1
        phantom = spawn 'phantomjs', ['./lib/spectacular_phantomjs.js']
        phantom.stdout.on 'data', (data) -> print data.toString()
        phantom.stderr.on 'data', (data) -> print data.toString()
        phantom.on 'exit', (status) ->
          console.log status
          exe.kill 'SIGINT'
          process.exit status


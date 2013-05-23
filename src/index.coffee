require 'colors'

cli = require './cli'
server = require './server'

exports.run = (options) ->
  if options.server
    server.run options
  else
    cli.run options


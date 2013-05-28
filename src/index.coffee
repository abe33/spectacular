require 'colors'

exports.run = (options) ->
  require(if options.server then './server' else './cli').run options


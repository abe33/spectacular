require 'colors'


exports.run = (options) ->
  if options.server
    require('./server').run options
  else
    require('./cli').run options


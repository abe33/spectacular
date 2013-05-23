Q = require 'q'
path = require 'path'
express = require 'express'

exports.run = (options) ->
  app = express()

  app.use '/assets/js', express.static path.resolve '.', 'lib'

  app.listen 5000
  console.log 'Server listening on port 5000'.cyan

  Q.defer().promise


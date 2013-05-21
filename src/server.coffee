Q = require 'q'
http = require 'http'

exports.run = (options) ->
  server = http.createServer (request, response) ->
    console.log request
    response.write 'hello world'

  server.listen 5000
  Q.defer().promise

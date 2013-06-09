exports.sample =
  match: ->
    @description = 'sample description'
    @message = 'sample message'

    true

exports.timeout =
  timeout: 100
  match: ->
    @description = 'timing out promise based matcher'
    @message = 'matcher message'

    new spectacular.Promise

exports.throwing =
  match: ->
    throw new Error 'foo'

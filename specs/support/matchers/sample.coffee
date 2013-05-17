exports.sample =
  assert: ->
    @description = 'sample description'
    @message = 'sample message'

    true

exports.timeout =
  timeout: 100
  assert: ->
    @description = 'timing out promise based matcher'
    @message = 'matcher message'

    new spectacular.Promise

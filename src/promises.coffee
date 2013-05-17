
#### Promise

class spectacular.Promise
  @unit: ->
    promise = new spectacular.Promise
    promise.resolve 0
    promise

  @all: (promises) ->
    promise = new spectacular.Promise
    solved = 0
    results = []

    promises.forEach (p) ->
      p
      .then (value) ->
        solved++
        results[promises.indexOf p] = value
        promise.resolve results if solved is promises.length

      .fail (reason) ->
        promise.reject reason

    promise

  constructor: ->
    @pending = true
    @fulfilled = null
    @value = undefined

    @fulfilledHandlers = []
    @errorHandlers = []
    @progressHandlers = []

  isPending: -> @pending
  isResolved: -> not @pending
  isFulfilled: -> not @pending and @fulfilled
  isRejected: -> not @pending and not @fulfilled

  then: (fulfilledHandler, errorHandler, progressHandler) ->
    promise = new spectacular.Promise
    f = (value)->
      res = fulfilledHandler? value
      if res?.then?
        res
        .then (value) ->
          promise.resolve value
        .fail (reason) ->
          promise.reject reason
      else
        promise.resolve res
    e = (reason) ->
      errorHandler? reason
      promise.reject reason

    if @pending
      @fulfilledHandlers.push f
      @errorHandlers.push e
      @progressHandlers.push progressHandler if progressHandler?
    else
      if @fulfilled
        f @value
      else
        e @

    promise

  fail: (errorHandler) -> @then (->), errorHandler

  resolve: (@value) ->
    return unless @pending

    @fulfilled = true
    @notifyHandlers()
    @pending = false

  reject: (reason) ->
    return unless @pending

    @reason = reason
    @fulfilled = false
    @notifyHandlers()
    @pending = false

  notifyHandlers: ->
    return unless @pending

    if @fulfilled
      handler @value for handler in @fulfilledHandlers
    else
      handler @reason for handler in @errorHandlers

class spectacular.AsyncPromise extends spectacular.Promise
  constructor: ->
    @interval = null
    @timeout = 5000
    @message = 'Timed out'
    super()

  run: =>
    lastTime = new Date()
    @interval = setInterval =>
      if new Date() - lastTime >= @timeout
        @reject new Error @message
    , 10

  reject: (reason) ->
    clearInterval @interval
    super reason

  resolve: (value) ->
    clearInterval @interval
    super value

  rejectAfter: (@timeout, @message) ->

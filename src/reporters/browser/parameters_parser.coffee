
class spectacular.URLParameters
  constructor: (parameters) ->
    tuples = String(parameters).split('&').map((tuple) -> tuple.split('='))

    console.log tuples


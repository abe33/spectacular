
if typeof module is 'undefined'
  only describe spectacular.URLParameters, ->
    context 'when created with a query string', ->
      given 'params', -> 'foo=bar&bar=1&bar=2&baz[foo]=bar'
      subject -> new spectacular.URLParameters @params

      its 'foo', -> should equal 'bar'
      its 'bar', -> should equal [1,2]
      its 'baz', -> should equal foo: 'bar'


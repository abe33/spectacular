
if typeof module is 'undefined'
  describe spectacular.URLParameters, ->
    context 'when created with a query string', ->
      given 'params', ->
        'foo=bar&bar[]=1&bar[]=2&bar[2][foo]=bar&baz[foo]=bar&bar[2][baz]=foo'

      subject -> new spectacular.URLParameters @params

      its 'foo', -> should equal 'bar'
      its 'bar', -> should equal [ '1', '2', {foo: 'bar', baz: 'foo'} ]
      its 'baz', -> should equal foo: 'bar'


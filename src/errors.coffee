URI_RE = '((http:\\/\\/)?.*\\.(js|coffee))(\\?[^:]*)*'
LINE_RE = ':(\\d+)(:(\\d+))*'

spectacular.errors = {}

class spectacular.errors.GeckoParser
  match: (stack) -> /@/g.test stack
  filter: (line) -> /@/.test line
  details: (line) ->
    re = ///\s*([^\s]*)(@)#{URI_RE}#{LINE_RE}///
    [match, method, p, file, h, e, q, line, c, column] = re.exec line

    {file, line, column, method}

class spectacular.errors.V8Parser
  match: (stack) -> /\s+at\s+/g.test stack
  filter: (line) -> /\s+at\s+/.test line
  details: (line) ->
    re = ///(at\s*([^\s]*)\s*\(|\()#{URI_RE}#{LINE_RE}///
    [match, p, method, file, h, e, q, line, c, column] = re.exec line

    {file, line, column, method, params: q}

class spectacular.errors.ErrorParser
  @supportedFormats = [
    new spectacular.errors.V8Parser
    new spectacular.errors.GeckoParser
  ]

  constructor: (@stack) ->
    @detectFormat()
    @splitLines()

  splitLines: ->
    @lines = @stack.split('\n').filter @format.filter
    @size = @lines.length

  detectFormat: ->
    @format = format for format in ErrorParser.supportedFormats when format.match(@stack)

  find: (query) -> @lines.filter (line) -> ///#{query}///.test line

  details: (line) -> @format.details line

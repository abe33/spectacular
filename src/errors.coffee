URI_RE = '((http:\\/\\/)?.*\\.(js|coffee))(\\?[^:]*)*'

class GeckoMatch
  match: (stack) -> /@/g.test stack
  filter: (line) -> /@/.test line
  details: (line) ->
    re = ///\s*([^\s]*)(@)#{URI_RE}:(\d+)(:(\d+))*///
    [match, method, p, file, h, e, q, line, c, column] = re.exec line

    {file, line, column, method}

class V8Match
  match: (stack) -> /\s+at\s+/g.test stack
  filter: (line) -> /\s+at\s+/.test line
  details: (line) ->
    re = ///(at\s*([^\s]*)\s*\(|\()#{URI_RE}:(\d+)(:(\d+))*///
    [match, p, method, file, h, e, q, line, c, column] = re.exec line

    {file, line, column, method, params: q}

class spectacular.ErrorParser
  @supportedFormats = [
    new V8Match
    new GeckoMatch
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

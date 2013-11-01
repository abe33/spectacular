
spectacular.BrowserMethods = (options) ->
  cache = {}
  loaders = {}

  unless options.valueOutput?
    options.valueOutput = (value) ->
      "<span class='value'>#{options.htmlSafe String(value)}</span>"


  unless options.htmlSafe?
    options.htmlSafe = (str) ->
      str
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')

  unless options.loadFile?
    options.loadFile = (file) ->
      promise = new spectacular.Promise

      if file of cache
        setTimeout (-> promise.resolve cache[file]), 0
        return promise

      if file of loaders
        loaders[file].push (data) -> promise.resolve data
        return promise

      req = new XMLHttpRequest()
      req.onload = ->
        data = @responseText
        loaders[file].forEach (f) -> f data

      listener = (data) -> promise.resolve cache[file] = data
      loaders[file] = [listener]

      req.open 'get', file, true
      req.send()

      promise

  unless options.getOriginalSourceFor?
    options.getOriginalSourceFor = (file, line, column) ->
      promise = new spectacular.Promise

      fileSource = null
      @loadFile(@getSourceURLFor file)
      .then (source) =>
        fileSource = source
        @loadFile(@getSourceMapURLFor file)
      .then (sourceMap) =>
        consumer = new window.sourceMap.SourceMapConsumer sourceMap
        {line, column} = consumer.originalPositionFor {line, column}
        promise.resolve {content: fileSource, line, column}
      .fail =>
        @loadFile(file).then (content) ->
          promise.resolve {content, line, column}

      promise

  # These are the concrete methods that you can define to enable source map.
  unless options.hasSourceMap?
    options.hasSourceMap = (file) -> false

  unless options.getSourceURLFor?
    options.getSourceURLFor = (file) ->

  unless options.getSourceMapURLFor?
    options.getSourceMapURLFor = (file) ->

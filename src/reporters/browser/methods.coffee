
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

      success = (data) -> promise.resolve data
      failure = (reason) -> promise.reject reason

      if file of cache
        setTimeout((-> success cache[file]), 0)
        return promise

      if file of loaders
        loaders[file].push {success, failure}
        return promise

      req = new XMLHttpRequest()
      req.onload = ->
        data = @responseText
        cache[file] = data
        if req.status >= 400
          loaders[file].forEach (f) -> f.failure new Error data
        else
          loaders[file].forEach (f) -> f.success data

      loaders[file] = [{success, failure}]

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

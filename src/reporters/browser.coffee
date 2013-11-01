
class spectacular.BrowserReporter
  constructor: (@runner, @widgets) ->
    {@options} = @runner

    @registerEvents()

  registerEvents: ->
    @runner.on 'start', @onStart
    @runner.on 'result', @onResult
    @runner.on 'end', @onEnd

  unregisterEvents: ->
    @runner.off 'start', @onStart
    @runner.off 'result', @onResult
    @runner.off 'end', @onEnd

  init: ->
    @container = tag 'div', id: 'container'
    document.body.appendChild @container

    @widgets.forEach (w) => w.init(@runner, this)

    @initSnapper()

  initSnapper: ->
    @snapper = new Snap
      element: @container.querySelector('#examples')
      minPosition: -viewerSize()

    @container.querySelector('#viewer').setAttribute 'style', "width: #{viewerSize()}px;"
    @snapper.open 'left'

    previousOnResize = document.body.onresize
    document.body.onresize = =>
      @snapper.close()
      @snapper.settings minPosition: -viewerSize()
      @container.querySelector('#viewer').setAttribute 'style', "width: #{viewerSize()}px;"

  onStart: (e) => @widgets.forEach (w) => w.onStart(e)
  onResult: (e) => @widgets.forEach (w) -> w.onResult e
  onEnd: (e) => @widgets.forEach (w) -> w.onEnd e

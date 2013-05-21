spectacular.factories ||= {}

spectacular.factories.buildMethodsCache = {}
spectacular.factories.build = (ctor, args=[]) ->
  f = if spectacular.factories.buildMethodsCache[args.length]?
    spectacular.factories.buildMethodsCache[args.length]
  else
    argumentsSignature = ''
    comma = ''
    if args.length > 0
      argumentsSignature = ("arg#{n}" for n in [0..args.length-1]).join(',')
      comma = ','

    spectacular.factories.buildMethodsCache[args.length] = new Function(
      "ctor#{comma}#{argumentsSignature}",
      "return new ctor(#{argumentsSignature});"
    )
  f.apply null, [ctor].concat(args)

class spectacular.factories.Set
  constructor: (@property, @value) ->

  apply: (instance) ->
    if typeof @value is 'function'
      instance[@property] = @value()
    else
      instance[@property] = @value

class spectacular.factories.Trait
  @EXPOSED_PROPERTIES = 'set'.split(/\s+/g)

  constructor: (@name) ->
    @previous = {}
    @setters = []

  set: (property, value) =>
    @setters.push new spectacular.factories.Set property, value

  applySet: (instance) ->
    @setters.forEach (setter) -> setter.apply instance

  load: ->
    @constructor.EXPOSED_PROPERTIES.forEach (k) =>
      @previous[k] = global[k] if global[k]?
      global[k] = @[k]

  unload: ->
    @constructor.EXPOSED_PROPERTIES.forEach (k) =>
      if @previous[k]?
        global[k] = @previous[k]
      else
        delete global[k]

class spectacular.factories.Factory extends spectacular.factories.Trait
  @EXPOSED_PROPERTIES = 'set trait'.split(/\s+/g)

  constructor: (name, @class) ->
    super name
    @traits = {}

  trait: (name, block) =>
    trait = @traits[name] ||= new spectacular.factories.Trait name
    trait.load()
    block.call(trait)
    trait.unload()

  build: (traits, options={}) ->
    instance = build @class
    @applySet instance
    @traits[trait].applySet instance for trait in traits
    instance[k] = v for k,v of options
    instance

spectacular.factoriesCache = {}
spectacular.factories.factory = (name, options, block) ->
  cache = spectacular.factoriesCache
  fct = cache[name] ||= new spectacular.factories.Factory name, options.class
  fct.load()
  block.call(fct)
  fct.unload()

spectacular.factories.create = (name, traits..., options) ->
  throw new Error 'no factory name provided' unless name?
  if typeof options is 'string'
    traits.push options
    options = null

  fct = spectacular.factoriesCache[name]
  throw new Error "missing factory #{name}" unless fct?
  fct.build(traits, options)

global.build = spectacular.factories.build
global.create = spectacular.factories.create
global.factory = spectacular.factories.factory

build._name = 'build'
create._name = 'create'
factory._name = 'factory'

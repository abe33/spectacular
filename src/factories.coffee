spectacular.factories ||= new spectacular.GlobalizableObject 'build',
                                                             'create',
                                                             'factory'
spectacular.factories.keepContext = false

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
  @include spectacular.Globalizable

  globalizable: 'set createWith'.split(/\s+/g)

  constructor: (@name) ->
    @previous = {}
    @setters = []

  set: (property, value) ->
    @setters.push new spectacular.factories.Set property, value

  createWith: (@arguments...) ->

  applySet: (instance) ->
    @setters.forEach (setter) -> setter.apply instance

class spectacular.factories.Factory extends spectacular.factories.Trait
  globalizable: 'set trait createWith'.split(/\s+/g)

  constructor: (name, @class) ->
    super name
    @traits = {}

  trait: (name, block) ->
    trait = @traits[name] ||= new spectacular.factories.Trait name
    trait.globalize()
    block.call(trait)
    trait.unglobalize()

  build: (traits, options={}) ->
    args = @traits[trait].arguments for trait in traits
    args ||= @arguments or []

    instance = build @class, args
    @applySet instance
    @traits[trait].applySet instance for trait in traits
    instance[k] = v for k,v of options
    instance

spectacular.factoriesCache = {}
spectacular.factories.factory = (name, options, block) ->
  cache = spectacular.factoriesCache
  fct = cache[name] ||= new spectacular.factories.Factory name, options.class
  fct.globalize()
  block.call(fct)
  fct.unglobalize()

spectacular.factories.create = (name, traits..., options) ->
  throw new Error 'no factory name provided' unless name?
  if typeof options is 'string'
    traits.push options
    options = null

  fct = spectacular.factoriesCache[name]
  throw new Error "missing factory #{name}" unless fct?
  fct.build(traits, options)


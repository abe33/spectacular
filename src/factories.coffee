spectacular = spectacular or {}
spectacular.factories ||= {}

spectacular.factories.buildMethodsCache = {}
spectacular.factories.build = (ctor, args) ->
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

spectacular.factories.factory = (name, block) ->


global.build = spectacular.factories.build
global.factory = spectacular.factories.factory

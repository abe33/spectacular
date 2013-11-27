
#### Core JS Extensions

unless Object.getPropertyDescriptor?
  Object.getPropertyDescriptor = (o, name) ->
    proto = o
    descriptor = undefined
    proto = Object.getPrototypeOf?(proto) or proto.__proto__ while proto and not (descriptor = Object.getOwnPropertyDescriptor(proto, name))
    descriptor

unless Function::include?
  Function::include = (mixins...) ->
    excluded = ['constructor', 'excluded']
    for mixin in mixins
      excl = excluded.concat()
      excl = excl.concat mixin::excluded if mixin::excluded?
      @::[k] = v for k,v of mixin.prototype when k not in excl
      mixin.included? this

    this

unless Function::extend?
  Function::extend = (mixins...) ->
    excluded = ['extended', 'excluded', 'included']
    for mixin in mixins
      excl = excluded.concat()
      excl = excl.concat mixin.excluded if mixin.excluded?
      @[k] = v for k,v of mixin when k not in excl
      mixin.extended? this

    this

unless Function::concern?
  Function::concern = (mixins...) ->
    @include.apply(this, mixins)
    @extend.apply(this, mixins)

unless Function::getter?
  Function::getter = (name, block) ->
    oldDescriptor = Object.getPropertyDescriptor @prototype, name
    set = oldDescriptor.set if oldDescriptor?
    Object.defineProperty @prototype, name, {
      get: block
      set: set
      configurable: true
      enumerable: true
    }
    this

unless Function::setter?
  Function::setter = (name, block) ->
    oldDescriptor = Object.getPropertyDescriptor @prototype, name
    get = oldDescriptor.get if oldDescriptor?
    Object.defineProperty @prototype, name, {
      set: block
      get: get
      configurable: true
      enumerable: true
    }
    this

unless Function::accessor?
  Function::accessor = (name, options) ->
    Object.defineProperty @prototype, name, {
      get: options.get
      set: options.set
      configurable: true
      enumerable: true
    }

unless Function::signature?
  Function::signature = ->
    re = ///
      ^function
      (\s+[a-zA-Z_][a-zA-Z0-9_]*)*
      \s*\(([^\)]+)\)
      ///
    re.exec(@toString())?[2].split(/\s*,\s*/) or []

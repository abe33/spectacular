
#### Core JS Extensions

Function::include = (mixins...) ->
  excluded = ['constructor']
  for mixin in mixins
    @::[k] = v for k,v of mixin.prototype when k not in excluded
    mixin.included? this

  this

Function::signature = ->
  re = ///
    ^function
    (\s+[a-zA-Z_][a-zA-Z0-9_]*)*
    \s*\(([^\)]+)\)
    ///
  re.exec(@toString())?[2].split(/\s*,\s*/) or []

Function::getter = (name, block) ->
  Object.defineProperty @prototype, name, {
    get: block
    configurable: true
    enumerable: true
  }
Function::setter = (name, block) ->
  Object.defineProperty @prototype, name, {
    set: block
    configurable: true
    enumerable: true
  }
Function::accessor = (name, options) ->
  Object.defineProperty @prototype, name, {
    get: options.get
    set: options.set
    configurable: true
    enumerable: true
  }

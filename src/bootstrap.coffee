spectacular = {}
isCommonJS = typeof window is "undefined"

if isCommonJS
  exports = exports or {}
else
  exports = window

exports.spectacular = spectacular

spectacular.version = '1.0.0'
spectacular.global = (->
  return window unless typeof window is 'undefined'
  return global unless typeof global is 'undefined'
  {}
)()

spectacular.nextTick = process?.setImmediate or
                       process?.nextTick or
                       (callback) -> setTimeout callback, 0

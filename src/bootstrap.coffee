spectacular = {}
isCommonJS = typeof window is "undefined"

if isCommonJS
  exports = exports or {}
else
  exports = window

exports.spectacular = spectacular

spectacular.version = '0.0.4'
spectacular.global = (->
  return window unless typeof window is 'undefined'
  return global unless typeof global is 'undefined'
  {}
)()

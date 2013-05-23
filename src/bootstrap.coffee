spectacular = {}
isCommonJS = typeof window is "undefined"

if isCommonJS
  exports = exports or {}
else
  exports = window

exports.spectacular = spectacular

f = -> this or global

spectacular.getGlobal = -> f.call(null)

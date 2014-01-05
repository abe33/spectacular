isCommonJS = typeof window is "undefined"

if isCommonJS
  exports = exports or {}
else
  exports = window

exports.spectacular = exports.spectacular or {}
spectacular = exports.spectacular

spectacular.version = '1.6.0'
spectacular.global = (->
  return window unless typeof window is 'undefined'
  return global unless typeof global is 'undefined'
  {}
)()

spectacular.deprecated = (message) ->
  parseLine = (line) ->
    if line.indexOf('@') > 0
      if line.indexOf('</') > 0
        [m, o, f] = /<\/([^@]+)@(.)+$/.exec line
      else
        [m, f] = /@(.)+$/.exec line
    else
      if line.indexOf('(') > 0
        [m, o, f] = /at\s+([^\s]+)\s*\(([^\)])+/.exec line
      else
        [m, f] = /at\s+([^\s]+)/.exec line

    [o,f]

  e = new Error()
  caller = ''
  if e.stack?
    s = e.stack.split('\n')
    [deprecatedMethodCallerName, deprecatedMethodCallerFile] = parseLine s[3]

    caller = if deprecatedMethodCallerName
      " (called from #{deprecatedMethodCallerName} at #{deprecatedMethodCallerFile})"
    else
       "(called from #{deprecatedMethodCallerFile})"

  console.log "DEPRECATION WARNING: #{message}#{caller}"

spectacular.deprecated._name = 'deprecated'

spectacular.nextTick = process?.setImmediate or
                       process?.nextTick or
                       window?.setImmediate or
                       window?.nextTick or
                       (callback) -> setTimeout callback, 0

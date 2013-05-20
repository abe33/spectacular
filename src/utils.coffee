
exports.squeeze = (s) -> s.replace /\s+/g, ' '

exports.indent = (string, ind=4) ->
  s = ''
  s = "#{s} " for i in [0..ind-1]

  "#{s}#{string.replace /\n/g, "\n#{s}"}"

exports.padRight = (string, pad=4) ->
  string = string.toString()
  string = " #{string}" while string.length < pad
  string

exports.toggle = (value, c1, c2) -> if value then c2 else c1

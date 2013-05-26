spectacular.utils ||= {}

spectacular.utils.squeeze = (s) -> s.replace /\s+/g, ' '

spectacular.utils.indent = (string, ind=4) ->
  s = ''
  s = "#{s} " for i in [0..ind-1]

  "#{s}#{string.replace /\n/g, "\n#{s}"}"

spectacular.utils.padRight = (string, pad=4) ->
  string = string.toString()
  string = " #{string}" while string.length < pad
  string

spectacular.utils.toggle = (value, c1, c2) -> if value then c2 else c1

spectacular.formatters = {}

spectacular.formatters.CHAR_MAP =
  errored: 'E'
  failure: 'F'
  skipped: 'x'
  pending: '*'
  success: '.'

spectacular.formatters.COLOR_MAP =
  pending: 'yellow'
  skipped: 'magenta'
  failure: 'red'
  errored: 'yellow'
  success: 'green'

spectacular.formatters.BADGE_MAP =
  errored: 'error'
  failure: 'fail'

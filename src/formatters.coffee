spectacular.formatters = {}

spectacular.formatters.PROGRESS_CHAR_MAP = spectacular.formatters.CHAR_MAP =
  pending: '*'
  skipped: 'x'
  failure: 'F'
  errored: 'E'
  success: '.'

spectacular.formatters.PROGRESS_COLOR_MAP = spectacular.formatters.COLOR_MAP =
  pending: 'yellow'
  skipped: 'magenta'
  failure: 'red'
  errored: 'yellow'
  success: 'green'

spectacular.formatters.BADGE_MAP =
  errored: 'error'
  failure: 'fail'

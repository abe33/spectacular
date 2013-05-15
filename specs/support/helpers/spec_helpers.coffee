
exports.TEST_PATTERN = '\\[[^\\]]+\\]'
exports.EXAMPLE_PATTERN = '\\[Example\\([^\\]]+\\)\\]'
exports.EXAMPLE_GROUP_PATTERN = '\\[ExampleGroup\\([^\\]]+\\)\\]'

exports.virtualEnv = (desc) ->
  shouldFailWith: (re, block) ->


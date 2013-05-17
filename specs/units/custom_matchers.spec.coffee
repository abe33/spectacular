
describe sample, ->
  it -> should exist

virtualEnv('matcher returning timing out promise')
.shouldFailWith /1 failure/, ->
  describe timeout, ->
    it -> should timeout

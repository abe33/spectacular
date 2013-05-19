
describe sample, ->
  it -> should exist

runningSpecs('matcher returning timing out promise')
.shouldFailWith /1 failure/, ->
  describe timeout, ->
    it -> should timeout

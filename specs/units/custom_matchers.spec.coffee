describe 'the custom matcher', ->
  describe sample, ->
    it -> should exist
    it -> should sample

  describe parameterizableMatcher, ->
    it -> should exist
    it -> should parameterizableMatcher true, true

  describe chainableMatcher, ->
    it -> should exist
    it -> should chainableMatcher.chain true

  describe  initializableMatcher, ->
    it -> should exist
    it -> should initializableMatcher

  runningSpecs('matcher returning timing out promise')
  .shouldStopWith /can't create matcher foo without a match/, ->
    spectacular.matcher 'foo', ->

  runningSpecs('matcher returning timing out promise')
  .shouldFailWith /1 failure/, ->
    describe timeout, ->
      it -> should timeout

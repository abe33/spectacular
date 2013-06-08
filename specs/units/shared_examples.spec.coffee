
runningSpecs('a valid shared example')
.shouldSucceedWith /3 success, 3 assertions/, ->
  sharedExample 'a shared example', ->
    context 'shared context', ->
      it -> true.should be true

    it -> true.should be true

  describe 'something', ->
    itBehavesLike 'a shared example'

    it -> true.should be true


runningSpecs('two shared example with same name')
.shouldStopWith /shared example '.*' already registered/, ->
  sharedExample 'a shared example', ->
  sharedExample 'a shared example', ->

runningSpecs('an unregistered sharedExample')
.shouldStopWith /shared example '.*' not found/, ->
  describe 'something', ->
    itBehavesLike 'a shared example'

    it -> true.should be true


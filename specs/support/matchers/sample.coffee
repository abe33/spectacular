spectacular.matcher 'sample', ->
  description -> 'sample description'
  match -> true
  failureMessageForShould -> 'sample message'

spectacular.matcher 'parameterizableMatcher', ->
  takes 'value1', 'value2'
  description  -> 'parameterizableMatcher description'
  match -> @value1 and @value2
  failureMessageForShould -> 'parameterizableMatcher message'

spectacular.matcher 'chainableMatcher', ->
  match -> @value
  description -> 'chain'
  chain 'chain', (@value) ->

spectacular.matcher 'initializableMatcher', ->
  init -> @value = true
  match -> @value
  description -> 'initalized'

spectacular.matcher 'timeout', ->
  timeout 100
  description -> 'timing out promise based matcher'
  match -> new spectacular.Promise
  failureMessageForShould -> 'matcher message'

spectacular.matcher 'throwing', ->
  match -> throw new Error 'foo'

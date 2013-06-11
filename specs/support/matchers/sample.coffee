spectacular.matcher 'sample', ->
  match ->
    @description = 'sample description'
    @message = 'sample message'

    true

spectacular.matcher 'parameterizableMatcher', ->
  takes 'value1', 'value2'
  match ->
    @description = 'parameterizableMatcher description'
    @message = 'parameterizableMatcher message'

    @value1 and @value2

spectacular.matcher 'timeout', ->
  timeout 100
  match ->
    @description = 'timing out promise based matcher'
    @message = 'matcher message'

    new spectacular.Promise

spectacular.matcher 'throwing', ->
  match ->
    throw new Error 'foo'

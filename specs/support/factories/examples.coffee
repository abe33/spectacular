factory 'exampleGroup', class: spectacular.ExampleGroup, ->
  set 'description', 'Some group description'

factory 'expectation', class: spectacular.Expectation, ->
  createWith -> [null, null, equal 42, false, new Error]

  trait 'successful', ->
    set 'actual', 42
    set 'success', true
    set 'message', 'succeed'

  trait 'failure', ->
    set 'actual', 24
    set 'success', false
    set 'message', 'failed'

factory 'example', class: spectacular.Example, ->
  set 'ownDescription', 'Some example description'
  set 'parent', -> create 'exampleGroup'

  trait 'successful', ->
    after 'build', (example) ->
      example.result = {
        example
        state: 'success'
        hasFailures: -> false
        expectations: [create 'expectation', 'successful']
      }

  trait 'failure', ->
    after 'build', (example) ->
      example.result = {
        example
        state: 'failure'
        hasFailures: -> true
        expectations: [create 'expectation', 'failure']
      }



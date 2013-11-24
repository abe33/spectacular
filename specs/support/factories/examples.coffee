factory 'exampleGroup', class: spectacular.ExampleGroup, ->
  set 'ownDescription', 'Some group description'

  trait 'with root', ->
    set 'parent', -> create 'exampleGroup'

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
  set 'parent', -> create 'exampleGroup', 'with root'

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

  trait 'errored', ->
    after 'build', (example) ->
      example.result = {
        example
        state: 'errored'
        hasFailures: -> false
        expectations: []
      }


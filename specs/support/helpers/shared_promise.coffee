sharedExample 'a formatter', ->
  specify 'the returned promise value', (async) ->
    @subject.then (result) =>
      expect(result).to equal @expected
      async.resolve()
    .fail (reason) ->
      async.reject reason

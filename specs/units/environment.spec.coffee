
describe describe, ->
  virtualEnv('called in a describe block')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      describe 'bar', ->
        subject -> true
        it -> should be true

  environmentMethod('describe').cannotBeCalledInsideIt()

describe should, ->
  virtualEnv('called inside it')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      subject -> true
      it -> should be true

  virtualEnv('called outside it')
  .shouldStopWith /should called outside a it block/, ->
    describe 'foo', ->
      should be true


describe 'top level', id: 'top', ->
  describe 'success', ->
    it -> true.should be true

describe 'failure', id: 'failure', ->
  it -> false.should be true


describe 'depends', ->
  dependsOn 'top'
  dependsOn 'failure'

  it 'should pass', ->
    true.should be true

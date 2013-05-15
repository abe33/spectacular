
virtualEnv('example depending on succeeding examples')
.shouldSucceedWith /3 success, 3 assertions, 0 failures, 0 skipped/, ->
  describe 'dependency 1', id: 'success1', ->
    it -> true.should be true

  describe 'dependency 2', id: 'success2', ->
    it -> true.should be true

  describe 'dependent', ->
    dependsOn 'success1'
    dependsOn 'success2'

    it -> true.should be true


virtualEnv('example depending on a failing example')
.shouldFailWith /1 failure, 1 skipped/, ->
  describe 'dependency', id: 'top', ->
    context 'succeeding', ->
      it -> true.should be true

  describe 'dependency failing', id: 'failure', ->
    it -> false.should be true

  describe 'dependent', ->
    dependsOn 'top'
    dependsOn 'failure'

    it 'should be skipped', ->
      true.should be true

virtualEnv('parent depending on child')
.shouldStopWith /can't depends on ancestor/, ->
  describe 'parent', id: 'parent1', ->
    context 'child', id: 'child1', ->
      dependsOn 'parent1'

      it -> true.should be true

virtualEnv('child depending on parent')
.shouldStopWith /can't depends on ancestor/, ->
  describe 'parent', id: 'parent2', ->
    dependsOn 'child2'

    context 'child', id: 'child2', ->
      it -> true.should be true

virtualEnv('circular dependencies')
.shouldStopWith /circular dependencies between/, ->
  describe 'cycle 1', id: 'c1', ->
    dependsOn 'c2'

    it -> true.should be true

  describe 'cycle 2', id: 'c2', ->
    dependsOn 'c1'

    it -> true.should be true

virtualEnv('deep circular dependencies')
.shouldStopWith /circular dependencies between/, ->
  describe 'cycle 1', id: 'c1', ->
    describe 'child 1', id: 'cc1', ->
      dependsOn 'c2'

    it -> true.should be true

  describe 'cycle 2', id: 'c2', ->
    dependsOn 'cc1'

    it -> true.should be true

virtualEnv('n+1 circular dependencies')
.shouldStopWith /circular dependencies between/, ->
  describe 'cycle 1', id: 'c1', ->
    dependsOn 'c2'

    it -> true.should be true

  describe 'cycle 2', id: 'c2', ->
    dependsOn 'c3'

    it -> true.should be true

  describe 'cycle 3', id: 'c3', ->
    dependsOn 'c1'

    it -> true.should be true

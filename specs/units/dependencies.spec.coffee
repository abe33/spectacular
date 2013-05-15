
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
.runShouldFailWith /can't depends on ancestor/, ->
  describe 'parent', id: 'parent1', ->
    context 'child', id: 'child1', ->
      dependsOn 'parent1'

      it -> true.should be true

virtualEnv('child depending on parent')
.runShouldFailWith /can't depends on ancestor/, ->
  describe 'parent', id: 'parent2', ->
    dependsOn 'child2'

    context 'child', id: 'child2', ->
      it -> true.should be true

virtualEnv('circular dependencies')
.runShouldFailWith /circular dependencies between/, ->
  describe 'cycle 1', id: 'c1', ->
    dependsOn 'c2'

    it -> true.should be true

  describe 'cycle 2', id: 'c2', ->
    dependsOn 'c1'

    it -> true.should be true

virtualEnv('deep circular dependencies')
.runShouldFailWith /circular dependencies between/, ->
  describe 'cycle 1', id: 'c1', ->
    describe 'child 1', id: 'cc1', ->
      dependsOn 'c2'

    it -> true.should be true

  describe 'cycle 2', id: 'c2', ->
    dependsOn 'cc1'

    it -> true.should be true

virtualEnv('n+1 circular dependencies')
.runShouldFailWith /circular dependencies between/, ->
  describe 'cycle 1', id: 'c1', ->
    dependsOn 'c2'

    it -> true.should be true

  describe 'cycle 2', id: 'c2', ->
    dependsOn 'c3'

    it -> true.should be true

  describe 'cycle 3', id: 'c3', ->
    dependsOn 'c1'

    it -> true.should be true

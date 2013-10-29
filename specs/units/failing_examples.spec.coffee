# Remove except to have various failing examples, useful when testing
# failures display
except describe 'Some test', ->
  describe 'Success', ->
    specify -> true.should be true

  describe 'Error', ->
    it -> throw new Error 'This is the error message'

  describe 'Failure', ->
    it -> fail()

    specify ->
      true.should be true
      true.should be true
      true.should be false
      true.should be true
      true.should be false

  describe 'Skipped', ->
    it -> skip()

  describe 'Pending', ->
    it -> pending()

describe "Socket Service", ->

  beforeEach angular.mock.module('phoenixSocket')
  beforeEach(inject((_$compile_, $rootScope) ->
    scope = $rootScope
    $compile = _$compile_
    return
  ))

  describe "doing stuff", ->
    it "does it", ->
      expect(1 == 1).toBeTruthy()

expect = require('chai').expect
navigator = require('../index')
# Helpers
console.inspect = (data, depth = 2, showHidden = false)->
  @log(require('util').inspect(data, showHidden, depth, true))

describe 'navigator', ->
  it 'should be an function', ->
    expect(navigator).to.be.an('function')
  it '.config should be an method', ->
    expect(navigator.config).to.be.a('function')

  it 'should throw an error when no argument is passed to it', ->
    expect(-> navigator.call(null)).to.throw(/You must pass a function/)
  it 'should return an empty object when an empty (or one that does not manipulate the passed arg) fn is provided to it', ->
    expect(navigator((makeRoute)->)).to.eql({})

  describe 'When passing route paths to the fn passed as argument to the provided fn passed to .setRoutes', ->
    it 'should return a restful version of the passed route in an routes object', ->
      routes = navigator (makeRoute)->
        makeRoute('/robots')
      console.inspect {routes}
      expectedRoutes =
        'GET /robots':  'RobotsController.index'
        'GET /robots/new': 'RobotsController.new'
        'POST /robots': 'RobotsController.create'
        'GET /robots/edit/:id':  'RobotsController.edit'
        'PUT /robots/:id':  'RobotsController.update'
        'DELETE /robots/:id':  'RobotsController.destroy'

      expect(routes).to.eql(expectedRoutes)
    describe 'When calling ', ->
      xit 'should return a restful version of the passed route in an routes object', ->
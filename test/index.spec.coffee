expect = require('chai').expect
navigator = require('../index')
_ = require('lodash')

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
    describe 'When calling sub-methods of the makeRoute fn (Which is passed by the navigator to the fn provided by the client)', ->
      describe.only '.REST', ->
        restfulRoutes =
          'GET /robots':  'RobotsController.index'
          'GET /robots/:id':  'RobotsController.show'
          'GET /robots/new': 'RobotsController.new'
          'POST /robots': 'RobotsController.create'
          'GET /robots/edit/:id':  'RobotsController.edit'
          'PUT /robots/:id':  'RobotsController.update'
          'DELETE /robots/:id':  'RobotsController.destroy'

        describe 'When passing "all" as argument', ->
          it 'should return a restful version of the passed route in a routes object', ->
            routes = navigator (makeRoute)->
              makeRoute('/robots')
                .REST('all')
            expect(routes).to.eql(restfulRoutes)

        describe 'When passing a list of the actions to include as argument', ->
          it 'should return a restful version of the passed route with only the included actions in a routes object', ->
            routes = navigator (makeRoute)->
              makeRoute('/robots')
              .REST('index', 'show')
            expectedRoutes = _.pick restfulRoutes, [
                _.findKey(restfulRoutes, (action)-> _.endsWith(action, 'index')),
                _.findKey(restfulRoutes, (action)-> _.endsWith(action, 'show'))
              ]

            expect(routes).to.eql(expectedRoutes)

        describe 'When passing a list of the actions to exclude as argument', ->
          it 'should return a restful version of the passed route with all but the excluded actions in a routes object', ->
            routes = navigator (makeRoute)->
              makeRoute('/robots')
                .REST('!', 'destroy')
            expectedRoutes = _.omit(restfulRoutes, _.findKey(restfulRoutes, (action)-> _.endsWith(action, 'destroy')))

            console.inspect {expectedRoutes}
            expect(routes).to.eql(expectedRoutes)

      # Custom routes Makers
      describe '.GET', ->
        it 'should add the custom path route (prefixed with route) to the routes object, and assigning it the defined controller action', ->
          routes = navigator (makeRoute)->
            makeRoute('/robots')
              .GET('/anaheim-machines': 'customIndex')

          expect(routes['GET /robots/anaheim-machines']).to.equal('RobotsController.customIndex')

      describe '.POST', ->
        it 'should add the custom path route (prefixed with route) to the routes object, and assigning it the defined controller action', ->
          routes = navigator (makeRoute)->
            makeRoute('/robots').POST('/anaheim-machines/:id': 'customCreate')
          expect(routes['POST /robots/anaheim-machines/:id']).to.equal('RobotsController.customCreate')

      describe '.PUT', ->
        it 'should add the custom path route (prefixed with route) to the routes object, and assigning it the defined controller action', ->
          routes = navigator (makeRoute)->
            makeRoute('/robots').PUT('/anaheim-machines/:id': 'customUpdate')
          expect(routes['PUT /robots/anaheim-machines/:id']).to.equal('RobotsController.customUpdate')

      describe '.PATCH', ->
        it 'should add the custom path route (prefixed with route) to the routes object, and assigning it the defined controller action', ->
          routes = navigator (makeRoute)->
            makeRoute('/robots').PATCH('/anaheim-machines/:id': 'customUpdate')
          expect(routes['PATCH /robots/anaheim-machines/:id']).to.equal('RobotsController.customUpdate')

      describe '.DELETE', ->
        it 'should add the custom path route (prefixed with route) to the routes object, and assigning it the defined controller action', ->
          routes = navigator (makeRoute)->
            makeRoute('/robots').DELETE('/anaheim-machines/:id': 'customDestroy')
          expect(routes['DELETE /robots/anaheim-machines/:id']).to.equal('RobotsController.customDestroy')

      describe '.GET_and_POST', ->
          it 'should add the custom path route (prefixed with route) for both verbs to the routes object, and assigning it the defined controller action', ->
            routes = navigator (makeRoute)->
              makeRoute('/robots').GET_and_POST('/anaheim-machines/new': 'customNew')
            expect(routes['GET /robots/anaheim-machines/new']).to.equal('RobotsController.customNew')
            expect(routes['POST /robots/anaheim-machines/new']).to.equal('RobotsController.customNew')

      describe '.ALL', ->
        it 'should add the custom path route (prefixed with route) for all verbs to the routes object, and assigning it the defined controller action', ->
          routes = navigator (makeRoute)->
            makeRoute('/robots').ALL('/anaheim-machines/ditto': 'customAction')

          expect(routes['GET /robots/anaheim-machines/ditto']).to.equal('RobotsController.customAction')
          expect(routes['POST /robots/anaheim-machines/ditto']).to.equal('RobotsController.customAction')
          expect(routes['PATCH /robots/anaheim-machines/ditto']).to.equal('RobotsController.customAction')
          expect(routes['PUT /robots/anaheim-machines/ditto']).to.equal('RobotsController.customAction')
          expect(routes['DELETE /robots/anaheim-machines/ditto']).to.equal('RobotsController.customAction')
expect = require('chai').expect
navigator = require('../index.coffee')
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
      restfulRoutes =
        'GET /robots':  'RobotsController.index'
        'GET /robots/:id':  'RobotsController.show'
        'GET /robots/new': 'RobotsController.new'
        'POST /robots/new': 'RobotsController.new' # For special cases when .create fails and post backs data to .new
        'POST /robots': 'RobotsController.create'
        'GET /robots/edit/:id':  'RobotsController.edit'
        'POST /robots/edit/:id':  'RobotsController.edit'  # For special cases when .update fails and post backs data to .edit
        'PUT /robots/:id':  'RobotsController.update'
        'DELETE /robots/:id':  'RobotsController.destroy'

      describe '.REST', ->
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

            expect(routes).to.eql( _.pick(restfulRoutes, [
                _.findKey(restfulRoutes, (action)-> _.endsWith(action, 'index')),
                _.findKey(restfulRoutes, (action)-> _.endsWith(action, 'show'))
              ]
            ))

        describe 'When passing a list of the actions to exclude as argument', ->
          it 'should return a restful version of the passed route with all but the excluded actions in a routes object', ->
            routes = navigator (makeRoute)->
              makeRoute('/robots')
                .REST('!', 'destroy')
            expectedRoutes = _.omit(restfulRoutes, _.findKey(restfulRoutes, (action)-> _.endsWith(action, 'destroy')))
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

      describe 'When the controllerName is specified before the action', ->
        it 'should take precedence over the guessed controller name(based on the route)', ->
          routes = navigator (makeRoute)->
            makeRoute('/')
            .GET('': 'HomeController.index')
          expect(routes['GET /']).to.equal('HomeController.index')

      describe '.path', ->
        it 'It should create a route with route passed to makeRoute as prefix', ->
          routes = navigator (makeRoute)->
            makeRoute('/admin')
              .path('/robots')
                .confOverride
                  rootAsControllerPath: true
                .GET('': 'index')

          expect(routes).to.eql('GET /admin/robots': 'admin/RobotsController.index')

        describe 'When chaining path', ->
          it 'It will always refer back to the initial route data', ->
            routes = navigator (makeRoute)->
              makeRoute('/admin')
                .confOverride
                    pathToRecordFormat: '*/:id/:slug'
                    rootAsControllerPath: true
                .path('/robots')
                  .confOverride
                      pathToRecordFormat: '*/:id'
                  .REST('update')
                .path('/articles')
                  .REST('update')

            expect(routes).to.eql(
              'PUT /admin/robots/:id': 'admin/RobotsController.update'
              'PUT /admin/articles/:id/:slug': 'admin/ArticlesController.update'
            )


      describe '.controller', ->
        describe 'When passing a custom controller', ->
          it 'should override the guessed controller default for a given route', ->
            customNamedController = 'InstitutionsController'
            routes = navigator (makeRoute)->
              makeRoute('/museums')
                .controller(customNamedController)
                .REST('index')

            expect(routes['GET /museums']).to.equal("#{customNamedController}.index")

      describe '.confOverride', ->
        describe 'When passing a custom controller', ->
          it 'should override the guessed controller default for a given route', ->
            customNamedController = 'InstitutionsController'
            routes = navigator (makeRoute)->
              makeRoute('/museums')
                .confOverride
                  controller: customNamedController
                .REST('index')

            expect(routes['GET /museums']).to.equal("#{customNamedController}.index")

        describe 'When overriding the default pathToRecordFormat', ->
          it 'should change how routes are built when using .REST', ->
            routes = navigator (makeRoute)->
              makeRoute('/articles')
                .confOverride
                  pathToRecordFormat: '*/:id/:slug'
                .REST('all')

            expectedRoutes =
              'GET /articles':  'ArticlesController.index'
              'GET /articles/:id/:slug':  'ArticlesController.show'
              'GET /articles/new': 'ArticlesController.new'
              'POST /articles/new': 'ArticlesController.new'
              'POST /articles': 'ArticlesController.create'
              'GET /articles/edit/:id/:slug':  'ArticlesController.edit'
              'POST /articles/edit/:id/:slug':  'ArticlesController.edit'
              'PUT /articles/:id/:slug':  'ArticlesController.update'
              'DELETE /articles/:id/:slug':  'ArticlesController.destroy'

            expect(routes).to.eql(expectedRoutes)

        describe 'When overriding the default localizeRoute', ->
          it 'should create the regular routes, as well as localized versions of it, based on a locale object', ->
            routes = navigator (makeRoute)->
              makeRoute('/articles')
                .confOverride
                  localizeRoute: ['en', 'es'] # Defaults to false
                  defaultLocale: 'en' # This is the module's default
                  localizedData: # Usually this should be avoided, a locales obj containing all routes locales should be passed to config instead
                    en: '/articles'
                    es: '/articulos'
                .REST('all')

            expectedRoutes =
              # En
              'GET /articles':  'ArticlesController.index'
              'GET /articles/:id':  'ArticlesController.show'
              'GET /articles/new': 'ArticlesController.new'
              'POST /articles/new': 'ArticlesController.new'
              'POST /articles': 'ArticlesController.create'
              'GET /articles/edit/:id':  'ArticlesController.edit'
              'POST /articles/edit/:id':  'ArticlesController.edit'
              'PUT /articles/:id':  'ArticlesController.update'
              'DELETE /articles/:id':  'ArticlesController.destroy'
              # Es
              'GET /es/articulos':  'ArticlesController.index'
              'GET /es/articulos/:id':  'ArticlesController.show'
              'GET /es/articulos/nuevo': 'ArticlesController.new'
              'POST /es/articulos/nuevo': 'ArticlesController.new'
              'POST /es/articulos': 'ArticlesController.create'
              'GET /es/articulos/editar/:id':  'ArticlesController.edit'
              'POST /es/articulos/editar/:id':  'ArticlesController.edit'
              'PUT /es/articulos/:id':  'ArticlesController.update'
              'DELETE /es/articulos/:id':  'ArticlesController.destroy'

            expect(routes).to.eql(expectedRoutes)

        describe 'When setting rootAsControllerPath as true', ->
          it 'should use the route\'s root path as the controllerPath', ->
            routes = navigator (makeRoute)->
              makeRoute('/admin/articles')
                .confOverride
                  rootAsControllerPath: true
                .REST('index')

            expectedRoutes =
              'GET /admin/articles':  'admin/ArticlesController.index'

            expect(routes).to.eql(expectedRoutes)


        it 'should only override the settings for a given route, and not the rest', ->
          customNamedController = 'InstitutionsController'
          routes = navigator (makeRoute)->
            makeRoute('/museums')
              .confOverride(controller: customNamedController)
              .REST('index')

            makeRoute('/artists')
              .REST('index')

          expect(routes['GET /museums']).to.equal("#{customNamedController}.index")
          expect(routes['GET /artists']).to.equal("ArtistsController.index")

  describe '.config', ->
    it 'should modify the module configuration when valid data is passed', ->
      navigator.config(
        localizeRoute: ['en', 'es']
        localizedData:
          '/articles': {en: '/articles', es: '/articulos'}
      )
      routes = navigator (makeRoute)->
        makeRoute('/articles')
          .REST('edit')
      expect(routes).to.eql(
        'GET /articles/edit/:id':  'ArticlesController.edit'
        'POST /articles/edit/:id':  'ArticlesController.edit'
        'GET /es/articulos/editar/:id':  'ArticlesController.edit'
        'POST /es/articulos/editar/:id':  'ArticlesController.edit'
      )

    it 'should throw an error when invalid settings(attributes) are passed'

  describe '.getConfig', ->
    it 'should return a copy of the configuration object', ->
      defaultConfig =
        pathToRecordFormat: '*/:id' #'route/:id/:slug'
        localizeRoute: false #['es', 'en']
        defaultLocale: 'en'
        prefixLocale: true
        skipLocalePrefixOnDefaultLocale: true
        localizedData: null
        restFullActionsLocalization:
          en: {edit: 'edit', new: 'new'}
          es: {edit: 'editar', new: 'nuevo'}
        rootAsControllerPath: false

      customConfig =
        pathToRecordFormat: '*/:id/:slug'
        localizeRoute: ['es', 'en']
        defaultLocale: 'en'
        prefixLocale: false
        localizedData:
          '/products': {en: '/products', es: '/productos'}
          '/articles': {en: '/articles', es: '/articulos'}

      config1  = navigator.config(defaultConfig).getConfig()
      config2  = navigator.config(customConfig).getConfig()

      expect(config1).to.eql(defaultConfig)
      expect(config2).to.eql(_.defaults({}, customConfig, defaultConfig))
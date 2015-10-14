# sails-navigator
A route manager system that creates sails.js routes in a more manageable way

### UNDER DEVELOPMENT (I just started :)

It will look something like this:
```coffeescript
navigator = require('navigator')

navigator.setRoutes (route)->
  route('/')
    .GET '': 'index'
    # Conf override
    .controller 'HomeController'

  # eg: GET /news/:id => NewsController.show
  route('/news')
    .REST('!', 'index')
    ### Custom Routes ###
    .GET('/follow': 'follow')
    .POST('/merge':  'merge')
    .GET('detach/:id': 'detach')
    .ALL('detach/:id': 'detach')
    .GET_and_POST('detach/:id': 'detach')

  route('/products')
    .REST 'all'
    # Conf override
    .localizeRoute('es', 'en')

  route('/store')
    .REST('index', 'show')
    # Conf override
    .localizeRoute true
```
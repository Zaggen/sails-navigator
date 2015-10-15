# sails-navigator
A route manager system that creates sails.js routes in a more manageable way

### UNDER DEVELOPMENT (I just started :)

It will look something like this:
```coffeescript
navigator = require('navigator')

navigator (makeRoute)->
  makeRoute('/')
    .GET '': 'HomeController.index'

  # eg: GET /news/:id => NewsController.show
  makeRoute('/news')
    .REST('!', 'index')
    ### Custom Routes ###
    .GET('/follow': 'follow')
    .POST('/merge':  'merge')
    .GET('detach/:id': 'detach')
    .ALL('detach/:id': 'detach')
    .GET_and_POST('detach/:id': 'detach')

  makeRoute('/products')
    .confOverride
      localizeRoute: ['en', 'es']
    .REST('all')

  makeRoute('/store')
    .REST('index', 'show')
```
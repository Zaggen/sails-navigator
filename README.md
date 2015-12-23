# sails-navigator
A route manager system that creates sails.js routes in a more manageable way

### UNDER DEVELOPMENT

```coffeescript
navigator = require('navigator')

navigator (makeRoute)->
  makeRoute('/')
    .GET '': 'HomeController.index'

  makeRoute('/news')
    .REST('!', 'index')
    ### Custom Routes ###
    .GET('/follow': 'follow')
    .POST('/merge':  'merge')
    .GET('detach/:id': 'detach')
    
  # The previous call generates this RESTful routes
    # GET /news/new => NewsController.new
    # POST /news/new => NewsController.new
    # GET /news/edit/:id => NewsController.edit
    # POST /news/edit/:id => NewsController.edit
    # DELETE /news/:id => NewsController.destroy
    # POST /news => NewsController.create
    # PUT /news:id => NewsController.update
    
    # And this custom routes
    # GET /news/follow => NewsController.follow
    # POST /news/merge => NewsController.merge
    # GET /detach/:id => NewsController.detach


  makeRoute('/products')
    .confOverride
      localizeRoute: ['en', 'es']
    .REST('all')

  makeRoute('/store')
    .REST('index', 'show')
```

I'll try to update the documentation with more info anytime soon.
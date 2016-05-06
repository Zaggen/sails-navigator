# sails-navigator
A route manager system that creates sails.js routes in a more manageable way

### UNDER DEVELOPMENT - Any help is welcome

### Examples

```javascript
var navigator = require('navigator');

navigator(function(makeRoute){
  makeRoute('/')
    .GET('': 'HomeController.index');

  makeRoute('/news')
    .REST('!', 'index')
    /* Custom Routes */
    .GET('/follow': 'follow')
    .POST('/merge':  'merge')
    .GET('detach/:id': 'detach');
    
    /*
    * The previous call generates this RESTful routes
    * GET /news/new => NewsController.new
    * POST /news/new => NewsController.new // Used to postBack data on 301 redirect
    * GET /news/edit/:id => NewsController.edit
    * POST /news/edit/:id => NewsController.edit // Used to postBack data on 301 redirect
    * DELETE /news/:id => NewsController.destroy
    * POST /news => NewsController.create
    * PUT /news/:id => NewsController.update
    
    * And this custom routes
    * GET /news/follow => NewsController.follow
    * POST /news/merge => NewsController.merge
    * GET /detach/:id => NewsController.detach
    */

})    
```

```javascript
var navigator = navigator = require('sails-navigator').config({
  pathToRecordFormat: '*/:id/:slug',
  localizeRoute: ['es', 'en'],
  defaultLocale: 'en',
  # LocalizedData should ideally go on an external file (It can be either JSON or a js object)
  localizedData: {
    '/': {en: '/', es:'/'}
    '/news': {en: '/news', es:'/noticias'}
  },
})

navigator(function(makeRoute){
  makeRoute('/')
    .GET('': 'HomeController.index');

  makeRoute('/news')
    .REST('index')
    
    /*
    * The previous call generates this RESTful routes
    * GET /news => NewsController.index
    * GET /news/new => NewsController.new
    * POST /news/new => NewsController.new
    * GET /news/edit/:id => NewsController.edit
    * POST /news/edit/:id => NewsController.edit
    * DELETE /news/:id => NewsController.destroy
    * POST /news => NewsController.create
    * PUT /news/:id => NewsController.update
    *
    * And the equivalent routes in spanish (Using localizedData)
    *
    * GET /es/noticias => NewsController.index
    * GET /es/noticias/nuevo => NewsController.new
    * POST /es/noticias/nuevo => NewsController.new
    * GET /es/noticias/editar/:id => NewsController.edit
    * POST /es/noticias/editar/:id => NewsController.edit
    * DELETE /es/noticias/:id => NewsController.destroy
    * POST /es/noticias => NewsController.create
    * PUT /es/noticias/:id => NewsController.update
    */

  makeRoute('/products')
    .confOverride({localizeRoute: ['en', 'es']})
    .REST('all');

})    
```

Note: `makeRoute` is a function passed as argument, to the function you provide to
the navigator, so it can be called as you wish, but we'll stick to that naming convention.

API:
- `navigator.config` Allows you to configure the settings for all routes, note that you can override this settings
on a route basis using `.confOverride`. The options it accepts are the following:
 - `pathToRecordFormat` (String): This is used by the `.REST` method to build restful routes, by default it uses `*/:id` to 
 create routes like `news/:id` but could change it to something like this `*/:id/:slug` to get `news/:id/:slug`
 - `localizeRoute` (Array|False): Specify which locales from the localizedData to use, i.e `['es', 'en']`
 - `defaultLocale` (String): Used to determine how to guess the controllerName, so in a multilingual situation, you only
 want one controller name, not one for language, by default this option is set to `en`
  localizedData: (Object): If you are using localizedRoutes then you need to pass a translations object, where each
  key is the default language Path and it contains keys with translations for each language supported. e.g 
  `{'/news', {en: 'news', es: 'noticias'}}`
  
  
- `makeRoute`
   - `.REST` (String): It creates all restfull routes you specify, and it tries to guess the controller based on the
    passed route. It accepts the following options
        - `'All'` It creates all restful routes index, show, edit, update and destroy
        - `'*'` An alias for `'All'`
        - `'index', 'show'` You can pass each route you want as a new argument
        - `'!', 'update'` If the first passed argument is a `'!'` it means, exclude the following routes


I'll try to update the documentation with more info anytime soon.
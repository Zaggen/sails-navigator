do ->
  _ = require('lodash')

  navigator = (fn)->
    if fn?
      navigator._routes = {}
      fn(_makeRoute) or {}
      routes = navigator._routes
      navigator._routes = null
      return routes
    else
      throw new Error('You must pass a function as argument')

  navigator.config = (options)->

  _makeRoute = (route)->
    currentRoutes = {}
    #_makeRestfulRoutes(route, currentRoutes)
    _.extend(navigator._routes, currentRoutes)
    # This allows chaining
    _makeRoute._currentRoot = route
    return _makeRoute

  _makeRoute.REST = (filter...)->
    restFulRoutes = _makeRestfulRoutes(filter, @_currentRoot)
    _.extend(navigator._routes, restFulRoutes)

  # Here we create methods to the _makeRoute that correspond to the http verbs
  # We make them one by one, instead of on a loop, to help the IDEs
  _makeRoute.GET = (pathObj)-> _makeCustomRoute.call(_makeRoute, 'GET', pathObj)
  _makeRoute.POST = (pathObj)-> _makeCustomRoute.call(_makeRoute, 'POST', pathObj)
  _makeRoute.PUT = (pathObj)-> _makeCustomRoute.call(_makeRoute, 'PUT', pathObj)
  _makeRoute.PATCH = (pathObj)-> _makeCustomRoute.call(_makeRoute, 'PATCH', pathObj)
  _makeRoute.DELETE = (pathObj)-> _makeCustomRoute.call(_makeRoute, 'DELETE', pathObj)

  _makeRoute.GET_and_POST = (pathObj)->
    @GET(pathObj)
    @POST(pathObj)

  VERBS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
  _makeRoute.ALL = (pathObj)->
    _.each VERBS, (VERB)->
      _makeRoute[VERB](pathObj)

  _makeCustomRoute = (VERB, pathObj)->
    for path, action of pathObj
      route = @_currentRoot
      controllerName = "#{_.capitalize(route.substr(1))}Controller"
      route += path
      navigator._routes["#{VERB} #{route}"] = "#{controllerName}.#{action}"
    return _makeRoute


  _makeRestfulRoutes = (filter, route)->
    controllerName = "#{_.capitalize(route.substr(1))}Controller"
    actions = {index: true, show: true, new: true, create: true,edit: true, update: true, destroy: true}
    unless filter[0] is 'all'
      actions = if filter[0] is '!' then _.omit(actions, filter) else _.pick(actions, filter)

    routeObj = {}
    if actions.index   then routeObj["GET #{route}"] = "#{controllerName}.index"
    if actions.show    then routeObj["GET #{route}/:id"] = "#{controllerName}.show"
    if actions.new     then routeObj["GET #{route}/new"] = "#{controllerName}.new"
    if actions.create  then routeObj["POST #{route}"] = "#{controllerName}.create"
    if actions.edit    then routeObj["GET #{route}/edit/:id"] = "#{controllerName}.edit"
    if actions.update  then routeObj["PUT #{route}/:id"] = "#{controllerName}.update"
    if actions.destroy then routeObj["DELETE #{route}/:id"] = "#{controllerName}.destroy"
    return routeObj


  #route.GET = ->
  ###route.POST = ->
  route.DELETE = ->
  route.PUT = ->
  route.GET_and_POST = ->
  route.ALL = ->
  route.controller = ->
  route.translateRoute = ->
  route.localizeRoute = ->
  route.restFulRoutes = ->
  route.RESTfulRoutes = ->
  route.REST = ->
  route.translateNameSpace = ->
  route.path = ->
  routeToRecordFormat= ->###

  module.exports = navigator
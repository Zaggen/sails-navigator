do ->
  _ = require('lodash')

  _config =
    # controller: null
    pathToRecordFormat: '*/:id' #'route/:id/:slug'
    localizeRoute: false #['es', 'en']
    defaultLocale: 'en'
    prefixLocale: true
    skipLocalePrefixOnDefaultLocale: true
    restFullActionsLocalization:
      en: {edit: 'edit', new: 'new'}
      es: {edit: 'editar', new: 'nuevo'}

  _routeConf = null
  _currentRoot = null
  # This vars are used by .path, to keep track of the original data set in
  # the _makeRoute instead of the one set via _makeRoute.path ...
  _originalRouteConf = null
  _originalCurrentRoot = null

  navigator = (fn)->
    if fn?
      navigator._routes = {}
      fn(_makeRoute) or {}
      routes = navigator._routes
      navigator._routes = null
      _routeConf = null
      return routes
    else
      throw new Error('You must pass a function as argument')

  navigator.config = (options)->
    _config = _.defaults({}, options, _config)
    return navigator

  navigator.getConfig = ()->
    return _.cloneDeep(_config)

  _makeRoute = (route)->
    _originalCurrentRoot = null
    _originalRouteConf = null
    currentRoutes = {}
    _routeConf = _config
    #_makeRestfulRoutes(route, currentRoutes)

    _.extend(navigator._routes, currentRoutes)
    # This allows chaining
    _currentRoot = route
    return _makeRoute

  _makeRoute.REST = (filter...)->
    locales = _routeConf.localizeRoute
    controllerName = _getControllerName()
    if _routeConf.localizeRoute
      for locale in locales
        if _routeConf.prefixLocale and not (locale is _routeConf.defaultLocale and _routeConf.skipLocalePrefixOnDefaultLocale)
          routePrefix = "/#{locale}"
        else
          routePrefix = ""
        localizedData = _routeConf.localizedData[_currentRoot]
        route = localizedData[locale]
        restFulRoutes = _makeRestfulRoutes(filter, controllerName, route, locale, routePrefix)
        _.extend(navigator._routes, restFulRoutes)
    else
      restFulRoutes = _makeRestfulRoutes(filter, controllerName, _currentRoot)
      _.extend(navigator._routes, restFulRoutes)

    return this

  # Here we create methods to the _makeRoute that correspond to the http verbs
  # We make them one by one, instead of on a loop, to help the IDEs
  _makeRoute.GET = (pathObj)->
    _makeCustomRoute.call(_makeRoute, 'GET', pathObj)
    return this
  _makeRoute.POST = (pathObj)->
    _makeCustomRoute.call(_makeRoute, 'POST', pathObj)
    return this
  _makeRoute.PUT = (pathObj)->
    _makeCustomRoute.call(_makeRoute, 'PUT', pathObj)
    return this
  _makeRoute.PATCH = (pathObj)->
    _makeCustomRoute.call(_makeRoute, 'PATCH', pathObj)
    return this
  _makeRoute.DELETE = (pathObj)->
    _makeCustomRoute.call(_makeRoute, 'DELETE', pathObj)
    return this

  _makeRoute.GET_and_POST = (pathObj)->
    @GET(pathObj)
    @POST(pathObj)
    return this

  VERBS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
  _makeRoute.ALL = (pathObj)->
    _.each VERBS, (VERB)->
      _makeRoute[VERB](pathObj)

  # When i call path, i should get the original _makeRoute data
  # which includes the _currentRoot and _routeConf
  _makeRoute.path = (path)->
    _originalCurrentRoot = _originalCurrentRoot or _currentRoot
    _originalRouteConf = _originalRouteConf or _routeConf
    _routeConf = _originalRouteConf
    _currentRoot = _originalCurrentRoot + path
    return _makeRoute

  # In case you want to keep .path data
  #_makeRoute.subPath = ->

  _makeRoute.confOverride = (options = {})->
    localizedData = {}
    if options.localizedData
      localizedData[_currentRoot] = options.localizedData
      localizedData = {localizedData}
      delete options.localizedData
    _routeConf = _.defaults({}, options, localizedData,  _routeConf)
    return this

  _makeRoute.controller = (controllerName)->
    _makeRoute.confOverride({controller: controllerName})
    return this

  _makeCustomRoute = (VERB, pathObj)->
    for path, action of pathObj
      route = _currentRoot
      controllerName = _getControllerName()
      # If the Controller is specified in the pathObj, it overrides any other controller options
      actionParts = action.split('.')
      if actionParts.length > 1
        controllerName = actionParts[0]
        action = actionParts[1]
      route += path
      navigator._routes["#{VERB} #{route}"] = "#{controllerName}.#{action}"
    return _makeRoute

  _makeRestfulRoutes = (filter, controllerName, route, locale = _config.defaultLocale, routePrefix = '')->
    singleRecordPathPostFix = _routeConf.pathToRecordFormat.replace('*/', '')
    actions = {index: true, show: true, new: true, create: true,edit: true, update: true, destroy: true}
    unless filter[0] is 'all'
      actions = if filter[0] is '!' then _.omit(actions, filter) else _.pick(actions, filter)

    routeObj = {}
    restfulActionPath = _config.restFullActionsLocalization[locale]

    if actions.index   then routeObj["GET #{routePrefix}#{route}"] = "#{controllerName}.index"
    if actions.show    then routeObj["GET #{routePrefix}#{route}/#{singleRecordPathPostFix}"] = "#{controllerName}.show"
    if actions.new     then routeObj["GET #{routePrefix}#{route}/#{restfulActionPath.new}"] = "#{controllerName}.new"
    if actions.create  then routeObj["POST #{routePrefix}#{route}"] = "#{controllerName}.create"
    if actions.edit    then routeObj["GET #{routePrefix}#{route}/#{restfulActionPath.edit}/#{singleRecordPathPostFix}"] = "#{controllerName}.edit"
    if actions.update  then routeObj["PUT #{routePrefix}#{route}/#{singleRecordPathPostFix}"] = "#{controllerName}.update"
    if actions.destroy then routeObj["DELETE #{routePrefix}#{route}/#{singleRecordPathPostFix}"] = "#{controllerName}.destroy"
    return routeObj

  _getControllerName = ->
    routeFragments = _currentRoot.split('/')
    lastPath = routeFragments.pop()
    root = routeFragments.join('/')
    root = if root is '' then '' else "#{root.substr(1)}/"
    guessedControllerName = "#{root}#{_.capitalize(lastPath)}Controller"
    return _routeConf.controller or guessedControllerName

  module.exports = navigator
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
    rootAsControllerPath: false

  _routeConf = null
  _currentRoute = null
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
    _currentRoute = route
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
        localizedData = _routeConf.localizedData[_currentRoute]
        route = localizedData[locale]
        restFulRoutes = _makeRestfulRoutes(filter, controllerName, route, locale, routePrefix)
        _.extend(navigator._routes, restFulRoutes)
    else
      restFulRoutes = _makeRestfulRoutes(filter, controllerName, _currentRoute)
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
  # which includes the _currentRoute and _routeConf
  _makeRoute.path = (path)->
    _originalCurrentRoot = _originalCurrentRoot or _currentRoute
    _originalRouteConf = _originalRouteConf or _routeConf
    _routeConf = _originalRouteConf
    _currentRoute = _originalCurrentRoot + path
    return _makeRoute

  # In case you want to keep .path data
  #_makeRoute.subPath = ->

  _makeRoute.confOverride = (options = {})->
    localizedData = {}
    if options.localizedData
      localizedData[_currentRoute] = options.localizedData
      localizedData = {localizedData}
      delete options.localizedData
    _routeConf = _.defaults({}, options, localizedData,  _routeConf)
    return this

  _makeRoute.controller = (controllerName)->
    _makeRoute.confOverride({controller: controllerName})
    return this

  _makeCustomRoute = (VERB, pathObj)->
    for path, action of pathObj
      route = _currentRoute
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

    # Since its likely that a controller may force the browser to post back on a failed .create to .new,
    # we add the POST option, so that this action can get this data.
    if actions.new     then routeObj["GET #{routePrefix}#{route}/#{restfulActionPath.new}"] = "#{controllerName}.new"
    if actions.new     then routeObj["POST #{routePrefix}#{route}/#{restfulActionPath.new}"] = "#{controllerName}.new"

    if actions.create  then routeObj["POST #{routePrefix}#{route}"] = "#{controllerName}.create"

    # Since its likely that a controller may force the browser to post back on a failed .update to .edit,
    # we add the POST option, so that this action can get this data.
    if actions.edit    then routeObj["GET #{routePrefix}#{route}/#{restfulActionPath.edit}/#{singleRecordPathPostFix}"] = "#{controllerName}.edit"
    if actions.edit    then routeObj["POST #{routePrefix}#{route}/#{restfulActionPath.edit}/#{singleRecordPathPostFix}"] = "#{controllerName}.edit"

    if actions.update  then routeObj["PUT #{routePrefix}#{route}/#{singleRecordPathPostFix}"] = "#{controllerName}.update"
    if actions.destroy then routeObj["DELETE #{routePrefix}#{route}/#{singleRecordPathPostFix}"] = "#{controllerName}.destroy"
    return routeObj

  _getControllerName = ->
    route = _currentRoute.substr(1)
    routeFragments = _.clone(route).split('/')
    guessedControllerName = _.capitalize(routeFragments.pop())
    if routeFragments.length > 0
      root = if _routeConf.rootAsControllerPath then "#{routeFragments.shift()}/" else ''
      prefix =_.map(routeFragments, (path)-> _.capitalize(path)).join('')
      guessedControllerName = root + prefix + guessedControllerName

    return _routeConf.controller or "#{guessedControllerName}Controller"

  module.exports = navigator
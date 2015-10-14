do ->
  _ = require('lodash')

  _makeRoute = (route)->
    routeObj = {}
    _makeRestfulRoutes(route, routeObj)
    return routeObj

  _makeRestfulRoutes = (route, routeObj)->
    controllerName = "#{_.capitalize(route.substr(1))}Controller"
    routeObj["GET #{route}"] = "#{controllerName}.index"
    routeObj["GET #{route}/new"] = "#{controllerName}.new"
    routeObj["POST #{route}"] = "#{controllerName}.create"
    routeObj["GET #{route}/edit/:id"] = "#{controllerName}.edit"
    routeObj["PUT #{route}/:id"] = "#{controllerName}.update"
    routeObj["DELETE #{route}/:id"] = "#{controllerName}.destroy"


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

  navigator = (fn)->
    if fn?
      return fn(_makeRoute) or {}
    else
      throw new Error('You must pass a function to .setRoutes')

  navigator.config = (options)->

  module.exports = navigator
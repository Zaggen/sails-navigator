// Generated by CoffeeScript 1.9.3
(function() {
  var slice = [].slice;

  (function() {
    var VERBS, _, _makeCustomRoute, _makeRestfulRoutes, _makeRoute, navigator;
    _ = require('lodash');
    navigator = function(fn) {
      var routes;
      if (fn != null) {
        navigator._routes = {};
        fn(_makeRoute) || {};
        routes = navigator._routes;
        navigator._routes = null;
        return routes;
      } else {
        throw new Error('You must pass a function as argument');
      }
    };
    navigator.config = function(options) {};
    _makeRoute = function(route) {
      var currentRoutes;
      currentRoutes = {};
      _.extend(navigator._routes, currentRoutes);
      _makeRoute._currentRoot = route;
      return _makeRoute;
    };
    _makeRoute.REST = function() {
      var filter, restFulRoutes;
      filter = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      restFulRoutes = _makeRestfulRoutes(filter, this._currentRoot);
      return _.extend(navigator._routes, restFulRoutes);
    };
    _makeRoute.GET = function(pathObj) {
      return _makeCustomRoute.call(_makeRoute, 'GET', pathObj);
    };
    _makeRoute.POST = function(pathObj) {
      return _makeCustomRoute.call(_makeRoute, 'POST', pathObj);
    };
    _makeRoute.PUT = function(pathObj) {
      return _makeCustomRoute.call(_makeRoute, 'PUT', pathObj);
    };
    _makeRoute.PATCH = function(pathObj) {
      return _makeCustomRoute.call(_makeRoute, 'PATCH', pathObj);
    };
    _makeRoute.DELETE = function(pathObj) {
      return _makeCustomRoute.call(_makeRoute, 'DELETE', pathObj);
    };
    _makeRoute.GET_and_POST = function(pathObj) {
      this.GET(pathObj);
      return this.POST(pathObj);
    };
    VERBS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
    _makeRoute.ALL = function(pathObj) {
      return _.each(VERBS, function(VERB) {
        return _makeRoute[VERB](pathObj);
      });
    };
    _makeCustomRoute = function(VERB, pathObj) {
      var action, controllerName, path, route;
      for (path in pathObj) {
        action = pathObj[path];
        route = this._currentRoot;
        controllerName = (_.capitalize(route.substr(1))) + "Controller";
        route += path;
        navigator._routes[VERB + " " + route] = controllerName + "." + action;
      }
      return _makeRoute;
    };
    _makeRestfulRoutes = function(filter, route) {
      var actions, controllerName, routeObj;
      controllerName = (_.capitalize(route.substr(1))) + "Controller";
      actions = {
        index: true,
        "new": true,
        create: true,
        edit: true,
        update: true,
        destroy: true
      };
      if (filter !== 'all') {
        true;
      }
      routeObj = {};
      if (actions.index) {
        routeObj["GET " + route] = controllerName + ".index";
      }
      if (actions["new"]) {
        routeObj["GET " + route + "/new"] = controllerName + ".new";
      }
      if (actions.create) {
        routeObj["POST " + route] = controllerName + ".create";
      }
      if (actions.edit) {
        routeObj["GET " + route + "/edit/:id"] = controllerName + ".edit";
      }
      if (actions.update) {
        routeObj["PUT " + route + "/:id"] = controllerName + ".update";
      }
      if (actions.destroy) {
        routeObj["DELETE " + route + "/:id"] = controllerName + ".destroy";
      }
      return routeObj;
    };

    /*route.POST = ->
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
    routeToRecordFormat= ->
     */
    return module.exports = navigator;
  })();

}).call(this);

//# sourceMappingURL=index.js.map

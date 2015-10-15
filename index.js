// Generated by CoffeeScript 1.9.3
(function() {
  var slice = [].slice;

  (function() {
    var VERBS, _, _config, _makeCustomRoute, _makeRestfulRoutes, _makeRoute, _routeConf, navigator;
    _ = require('lodash');
    _config = {
      pathToRecordFormat: '*/:id',
      localizeRoute: false,
      defaultLocale: 'en',
      prefixLocale: true,
      skipLocalePrefixOnDefaultLocale: true,
      restFullActionsLocalization: {
        en: {
          edit: 'edit',
          "new": 'new'
        },
        es: {
          edit: 'editar',
          "new": 'nuevo'
        }
      }
    };
    _routeConf = null;
    navigator = function(fn) {
      var routes;
      if (fn != null) {
        navigator._routes = {};
        fn(_makeRoute) || {};
        routes = navigator._routes;
        navigator._routes = null;
        _routeConf = null;
        return routes;
      } else {
        throw new Error('You must pass a function as argument');
      }
    };
    navigator.config = function(options) {
      _config = _.defaults({}, options, _config);
      return navigator;
    };
    navigator.getConfig = function() {
      return _.cloneDeep(_config);
    };
    _makeRoute = function(route) {
      var currentRoutes;
      currentRoutes = {};
      _routeConf = _config;
      _.extend(navigator._routes, currentRoutes);
      _makeRoute._currentRoot = route;
      return _makeRoute;
    };
    _makeRoute.REST = function() {
      var controllerName, filter, i, len, locale, locales, localizedData, restFulRoutes, route, routePrefix;
      filter = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      locales = _routeConf.localizeRoute;
      controllerName = _routeConf.controller || ((_.capitalize(this._currentRoot.substr(1))) + "Controller");
      if (_routeConf.localizeRoute) {
        for (i = 0, len = locales.length; i < len; i++) {
          locale = locales[i];
          if (_routeConf.prefixLocale && !(locale === _routeConf.defaultLocale && _routeConf.skipLocalePrefixOnDefaultLocale)) {
            routePrefix = "/" + locale;
          } else {
            routePrefix = "";
          }
          localizedData = _routeConf.localizedData[this._currentRoot];
          route = localizedData[locale];
          restFulRoutes = _makeRestfulRoutes(filter, controllerName, route, locale, routePrefix);
          _.extend(navigator._routes, restFulRoutes);
        }
      } else {
        restFulRoutes = _makeRestfulRoutes(filter, controllerName, this._currentRoot);
        _.extend(navigator._routes, restFulRoutes);
      }
      return this;
    };
    _makeRoute.GET = function(pathObj) {
      _makeCustomRoute.call(_makeRoute, 'GET', pathObj);
      return this;
    };
    _makeRoute.POST = function(pathObj) {
      _makeCustomRoute.call(_makeRoute, 'POST', pathObj);
      return this;
    };
    _makeRoute.PUT = function(pathObj) {
      _makeCustomRoute.call(_makeRoute, 'PUT', pathObj);
      return this;
    };
    _makeRoute.PATCH = function(pathObj) {
      _makeCustomRoute.call(_makeRoute, 'PATCH', pathObj);
      return this;
    };
    _makeRoute.DELETE = function(pathObj) {
      _makeCustomRoute.call(_makeRoute, 'DELETE', pathObj);
      return this;
    };
    _makeRoute.GET_and_POST = function(pathObj) {
      this.GET(pathObj);
      this.POST(pathObj);
      return this;
    };
    VERBS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
    _makeRoute.ALL = function(pathObj) {
      return _.each(VERBS, function(VERB) {
        return _makeRoute[VERB](pathObj);
      });
    };
    _makeRoute.confOverride = function(options) {
      var localizedData;
      if (options == null) {
        options = {};
      }
      localizedData = {};
      if (options.localizedData) {
        localizedData[this._currentRoot] = options.localizedData;
        localizedData = {
          localizedData: localizedData
        };
        delete options.localizedData;
      }
      _routeConf = _.defaults({}, options, localizedData, _routeConf);
      return this;
    };
    _makeCustomRoute = function(VERB, pathObj) {
      var action, actionParts, controllerName, guessedControllerName, path, route;
      for (path in pathObj) {
        action = pathObj[path];
        route = this._currentRoot;
        guessedControllerName = (_.capitalize(route.substr(1))) + "Controller";
        controllerName = _routeConf.controller || guessedControllerName;
        actionParts = action.split('.');
        if (actionParts.length > 1) {
          controllerName = actionParts[0];
          action = actionParts[1];
        }
        route += path;
        navigator._routes[VERB + " " + route] = controllerName + "." + action;
      }
      return _makeRoute;
    };
    _makeRestfulRoutes = function(filter, controllerName, route, locale, routePrefix) {
      var actions, restfulActionPath, routeObj, singleRecordPathPostFix;
      if (locale == null) {
        locale = _config.defaultLocale;
      }
      if (routePrefix == null) {
        routePrefix = '';
      }
      singleRecordPathPostFix = _routeConf.pathToRecordFormat.replace('*/', '');
      actions = {
        index: true,
        show: true,
        "new": true,
        create: true,
        edit: true,
        update: true,
        destroy: true
      };
      if (filter[0] !== 'all') {
        actions = filter[0] === '!' ? _.omit(actions, filter) : _.pick(actions, filter);
      }
      routeObj = {};
      restfulActionPath = _config.restFullActionsLocalization[locale];
      if (actions.index) {
        routeObj["GET " + routePrefix + route] = controllerName + ".index";
      }
      if (actions.show) {
        routeObj["GET " + routePrefix + route + "/" + singleRecordPathPostFix] = controllerName + ".show";
      }
      if (actions["new"]) {
        routeObj["GET " + routePrefix + route + "/" + restfulActionPath["new"]] = controllerName + ".new";
      }
      if (actions.create) {
        routeObj["POST " + routePrefix + route] = controllerName + ".create";
      }
      if (actions.edit) {
        routeObj["GET " + routePrefix + route + "/" + restfulActionPath.edit + "/" + singleRecordPathPostFix] = controllerName + ".edit";
      }
      if (actions.update) {
        routeObj["PUT " + routePrefix + route + "/" + singleRecordPathPostFix] = controllerName + ".update";
      }
      if (actions.destroy) {
        routeObj["DELETE " + routePrefix + route + "/" + singleRecordPathPostFix] = controllerName + ".destroy";
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

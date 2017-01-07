(function() {
  "use strict";

  angular
    .module("spa-demo.foos")
    .factory("spa-demo.foos.Foo", FooFactory);

  FooFactory.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function FooFactory($resource, APP_CONFIG) {
    return $resource(APP_CONFIG.server_url + "/api/foos/:id",
      { id: '@id'},
      { 
        update: { method: "PUT",
                  transformRequest: buildNestedBody },
        save: { method: "POST",
                  transformRequest: buildNestedBody }
      }
      );
  }

  //nests the default payload below a "foo" element 
  //as required by default by Rails API resources
  function buildNestedBody(data) {
   return angular.toJson({foo: data})
  }  
})();

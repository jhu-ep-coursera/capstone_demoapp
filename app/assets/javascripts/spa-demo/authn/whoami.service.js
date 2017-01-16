(function() {
  "use strict";

  angular
    .module("spa-demo.authn")
    .factory("spa-demo.authn.whoAmI", WhoAmIFactory);

  WhoAmIFactory.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function WhoAmIFactory($resource, APP_CONFIG) {
    return $resource(APP_CONFIG.server_url + "/authn/whoami");
  }
})();
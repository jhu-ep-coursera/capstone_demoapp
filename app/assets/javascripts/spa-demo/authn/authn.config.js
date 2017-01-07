(function() {
  "use strict";

  angular
    .module("spa-demo.authn")
    .config(AuthnConfig);

  AuthnConfig.$inject = ["$authProvider", "spa-demo.config.APP_CONFIG"];
  function AuthnConfig($authProvider, APP_CONFIG) {
    $authProvider.configure({
      apiUrl: APP_CONFIG.server_url
    });    
  }
    
})();
(function() {
  "use strict";

  angular
    .module("spa-demo", [
      "ui.router",
      "ngFileUpload",
      "uiCropper",      
      "spa-demo.config",
      "spa-demo.authn",
      "spa-demo.authz",
      "spa-demo.geoloc",
      "spa-demo.layout",
      "spa-demo.foos",
      "spa-demo.subjects"      
    ]);
})();

(function() {
  "use strict";

  angular
    .module("spa-demo", [
      "ui.router",
      "spa-demo.config",
      "spa-demo.authn",
      "spa-demo.foos"
    ]);
})();
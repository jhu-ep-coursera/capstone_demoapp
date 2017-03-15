(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .config(JhuLocationOverride);

  JhuLocationOverride.$inject=[];
  function JhuLocationOverride() {
  }
})();
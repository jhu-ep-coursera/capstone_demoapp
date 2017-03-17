(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .config(JhuLocationOverride);

  JhuLocationOverride.$inject=["spa-demo.geoloc.myLocationProvider"];
  function JhuLocationOverride(myLocationProvider) {
    myLocationProvider.usePositionOverride({
      longitude:-76.6200464, 
      latitude: 39.3304957      
    });
  }
})();

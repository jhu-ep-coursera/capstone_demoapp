(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .factory("spa-demo.geoloc.Map", GeolocMapFactory);

  GeolocMapFactory.$inject = ["$timeout","spa-demo.config.APP_CONFIG"];
  function GeolocMapFactory($timeout, APP_CONFIG) {
    function GeolocMap(element, mapOptions) {
      var service=this;
      service.options = {}
      service.markers = [];
      service.currentMarker = null;
      //service.options = ...
      //service.map = ...
    }

    GeolocMap.prototype.normalizeMapOptions = function(mapOptions) {
      //...
      return mapOptions;
    };

    GeolocMap.prototype.center = function(mapOptions) {
      //...
    };

    GeolocMap.prototype.getMarkers = function() {
      return this.markers;
    }
    GeolocMap.prototype.getCurrentMarker = function() {
      return this.currentMarker;
    }

    GeolocMap.prototype.clearMarkers = function() {
      //...
    }

    GeolocMap.prototype.displayMarker = function(markerOptions) {
      if (this.map) {
        //...
      }
    }

    GeolocMap.prototype.displayOriginMarker = function(content) {      
      console.log("displayOriginMarker", content, this.options.center);
      //...
    }

    GeolocMap.prototype.setActiveMarker = function(markerOptions) {
      console.log("setting new marker new/old:", markerOptions, this.currentMarker);
      //...
    }

    return GeolocMap;
  }
})();
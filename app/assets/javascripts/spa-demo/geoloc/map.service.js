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
      service.options = service.normalizeMapOptions(mapOptions);
      service.map = new google.maps.Map(element, service.options);    
    }

    GeolocMap.prototype.normalizeMapOptions = function(mapOptions) {
      if (mapOptions.center) {
        var lng = parseFloat(mapOptions.center.lng);
        var lat = parseFloat(mapOptions.center.lat);
        mapOptions.center = new google.maps.LatLng(lat, lng);
      }
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
      angular.forEach(this.markers, function(m){
        m.marker.setMap(null);
      });
      this.markers = [];
    }

    GeolocMap.prototype.displayMarker = function(markerOptions) {
      if (!this.map) { return; }
      markerOptions.optimized = APP_CONFIG.optimized_markers;
      console.log("markerOptions", markerOptions);

      //display the marker
      var marker = new google.maps.Marker(markerOptions);
      marker.setMap(this.map);

      //remember the marker
      markerOptions.marker = marker;
      this.markers.push(markerOptions);

      //size the map to fit all markers
      var bounds = new google.maps.LatLngBounds();
      angular.forEach(this.markers, function(marker){
        bounds.extend(marker.position);
      });

      //console.log("bounds", bounds);
      this.map.fitBounds(bounds);        

      return markerOptions;
    }

    GeolocMap.prototype.displayOriginMarker = function(content) {      
      console.log("displayOriginMarker", content, this.options.center);

      this.originMarker = this.displayMarker({
            position: this.options.center,
            title: "origin",
            icon: APP_CONFIG.origin_marker
      });
    }

    GeolocMap.prototype.setActiveMarker = function(markerOptions) {
      console.log("setting new marker new/old:", markerOptions, this.currentMarker);
      //...
    }








    return GeolocMap;
  }
})();
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
      if (this.map && mapOptions) {
        this.normalizeMapOptions(mapOptions);
        if (mapOptions.center) {
          this.options.center=mapOptions.center;
          this.map.setCenter(this.options.center);
        }
        if (mapOptions.zoom) {
          this.options.zoom = mapOptions.zoom;
          this.map.setZoom(this.options.zoom);
        }
        if (mapOptions.mapTypeId) {
          this.options.mapTypeId = mapOptions.mapTypeId;
          this.map.setMapTypeId(this.options.mapTypeId);
        }        
      }
    };

    GeolocMap.prototype.getMarkers = function() {
      return this.markers;
    }
    GeolocMap.prototype.getCurrentMarker = function() {
      return this.currentMarker;
    }

    GeolocMap.prototype.clearMarkers = function() {
      angular.forEach(this.markers, function(m){
        google.maps.event.removeListener(m.listener);
        m.marker.setMap(null);
      });
      this.markers = [];
    }
    GeolocMap.prototype.clearOriginMarker = function() {
      var m = this.originMarker;
      if (m) {
        google.maps.event.removeListener(m.listener);
        m.marker.setMap(null);
      };
      if (m === this.originMarker) {
        this.originMarker=null;
      }
    }

    GeolocMap.prototype.displayMarker = function(markerOptions) {
      if (!this.map) { return; }
      markerOptions.optimized = APP_CONFIG.optimized_markers;
      console.log("markerOptions", markerOptions);

      //display the marker
      var marker = new google.maps.Marker(markerOptions);
      marker.setMap(this.map);

      //add an info pop-up
      var service=this;
      var infoWindow=new google.maps.InfoWindow({content: markerOptions.content});                
      var listener=marker.addListener('click', function(){
        console.log("map listener called");
        service.setActiveMarker(markerOptions);
        $timeout();
      });

      //remember the marker
      markerOptions.marker = marker;
      markerOptions.infoWindow = infoWindow;
      markerOptions.listener = listener;
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
      if (!content) {
        content = "Origin";
      }

      var service = this;
      $timeout(function(){
        service.clearOriginMarker();
        service.originMarker = service.displayMarker({
              position: service.options.center,
              title: "origin",
              icon: APP_CONFIG.origin_marker,
              content: content
        });
      });
    }

    GeolocMap.prototype.setActiveMarker = function(markerOptions) {
      console.log("setting new marker new/old:", markerOptions, this.currentMarker);
      if (this.currentMarker && markerOptions !== this.currentMarker) {
        this.currentMarker.infoWindow.close();
      }
      if (markerOptions && markerOptions.infoWindow) {
        markerOptions.infoWindow.open(this.map, markerOptions.marker);        
      }
      this.currentMarker = markerOptions;
    }








    return GeolocMap;
  }
})();

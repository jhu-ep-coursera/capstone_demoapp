(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .provider("spa-demo.geoloc.myLocation", MyLocationProvider);

  MyLocationProvider.$inject = [];
  function MyLocationProvider() {
    var provider = this;

    //configure if we want to hard-code a specific current position
    provider.usePositionOverride = function(coords) {
      provider.positionOverride = coords;
    }

    function MyLocation() {      
    }

    provider.$get = ["$window", "$q", "spa-demo.geoloc.geocoder", 
                     function($window, $q, geocoder) {

      //returns true/false whether current location provided
      MyLocation.prototype.isCurrentLocationSupported = function() {   
        console.log("isCurrentLocationSupported", $window.navigator.geolocation != null);
        return $window.navigator.geolocation != null;     
      }

      //determines current position and returns the geocoded location information
      MyLocation.prototype.getCurrentLocation = function() {
        console.log("getCurrentLocation");
        var service = this;
        var deferred = $q.defer();        

        if (!this.isCurrentLocationSupported()) {
          deferred.reject("geolocation not supported by browser");
        } else {
          $window.navigator.geolocation.getCurrentPosition(
            function(position){ service.geocodeGeoposition(deferred, position); },
            function(err){ deferred.reject(err); }
            );
        }

        return deferred.promise;
      }                            

      //completes a deferred with the geocoded location of the current position
      MyLocation.prototype.geocodeGeoposition = function(deferred, position) {
        var pos = provider.positionOverride ? provider.positionOverride : position.coords;
        console.log("handleMyPosition", pos, geocoder);

        geocoder.getLocationByPosition({lng:pos.longitude, lat:pos.latitude}).$promise.then(
          function geocodeSuccess(location){
            console.log("locationResult", location);
            deferred.resolve(location);
          },
          function geocodeFailure(err){ 
            deferred.reject(err);
          });
      } 

      return new MyLocation();
    }];

    return;
    ////////////////
  }
})();
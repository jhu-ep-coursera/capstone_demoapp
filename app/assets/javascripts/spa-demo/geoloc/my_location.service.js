(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .provider("spa-demo.geoloc.myLocation", MyLocationProvider);

  MyLocationProvider.$inject = [];
  function MyLocationProvider() {
    var provider = this;

    function MyLocation() {      
    }

    provider.$get = ["$window", "$q", "spa-demo.geoloc.geocoder", 
                     function($window, $q, geocoder) {

      //returns true/false whether current location provided
      MyLocation.prototype.isCurrentLocationSupported = function() {   
        //console.log("isCurrentLocationSupported", $window.navigator.geolocation != null);
      }

      //determines current position and returns the geocoded location information
      MyLocation.prototype.getCurrentLocation = function() {
      }                            

      return new MyLocation();
    }];

    return;
    ////////////////
  }
})();
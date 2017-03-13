(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .service("spa-demo.geoloc.currentOrigin", CurrentOrigin);

  CurrentOrigin.$inject = ["$rootScope"];
  function CurrentOrigin($rootScope) {
    var service = this;
    this.version=0;
    this.location=null;
    this.distance=0;    

    return;
    ////////////////
  }
  CurrentOrigin.prototype.getVersion = function() {
    return this.version;
  }  
  CurrentOrigin.prototype.clearLocation = function() {
    this.location=null;
    this.version += 1;
  }  
  CurrentOrigin.prototype.setLocation = function(location) {
    this.location = angular.copy(location);
    this.version += 1;
  }
  CurrentOrigin.prototype.getLocation = function() {
    return this.location;
  }
  CurrentOrigin.prototype.getFormattedAddress = function() {
    return this.location ? this.location.formatted_address : null;
  }
  CurrentOrigin.prototype.getPosition = function() {
    return this.location && this.location.position ? 
        angular.copy(this.location.position) : null;
  }
  CurrentOrigin.prototype.getAddress = function() {
    return this.location && this.location.address ? 
        angular.copy(this.location.address) : null;
  }

  CurrentOrigin.prototype.setDistance = function(distance) {
    console.log("setDistance", distance);
    this.distance = distance;
    this.version += 1;
  }
  CurrentOrigin.prototype.getDistance = function() {
    return this.distance;
  }
})();
(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdCurrentSubjectsMap", {
      template: "<div id='map'></div>",
      controller: CurrentSubjectsMapController,
      bindings: {
        zoom: "@"
      }
    });

  CurrentSubjectsMapController.$inject = ["$scope", "$q", "$element",
                                          "spa-demo.geoloc.currentOrigin",
                                          "spa-demo.geoloc.myLocation",
                                          "spa-demo.geoloc.Map",
                                          "spa-demo.subjects.currentSubjects",
                                          "spa-demo.config.APP_CONFIG"];
  function CurrentSubjectsMapController($scope, $q, $element, 
                                        currentOrigin, myLocation, Map, currentSubjects, 
                                        APP_CONFIG) {
    var vm=this;

    vm.$onInit = function() {
      console.log("CurrentSubjectsMapController",$scope);
    }
    vm.$postLink = function() {
      var element = $element.find('div')[0];
      getLocation().then(
        function(location){
          vm.location = location;
          initializeMap(element, location.position);
        });
    }

    return;
    //////////////
    function getLocation() {
      var deferred = $q.defer();

      //use current address if set
      var location = currentOrigin.getLocation();
      if (!location) {
        //try my location next
        myLocation.getCurrentLocation().then(
          function(location){
            deferred.resolve(location);
          },
          function(){
            deferred.resolve({ position: APP_CONFIG.default_position});
          });
      } else {
        deferred.resolve(location);
      }

      return deferred.promise;
    }

    function initializeMap(element, position) {
      vm.map = new Map(element, {
        center: position,        
        zoom: vm.zoom || 18,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
    }

    function displaySubjects(){
      //...
    }

    function displaySubject(ti) {
      //...
    }
  }

  CurrentSubjectsMapController.prototype.updateOrigin = function() {
    //...
  }

  CurrentSubjectsMapController.prototype.setActiveMarker = function(thing_id, image_id) {
    //...
  }

  CurrentSubjectsMapController.prototype.originInfoWindow = function(location) {
    //...
  }
  CurrentSubjectsMapController.prototype.thingInfoWindow = function(ti) {
    //...
  }
  CurrentSubjectsMapController.prototype.imageInfoWindow = function(ti) {
    //...
  }


})();
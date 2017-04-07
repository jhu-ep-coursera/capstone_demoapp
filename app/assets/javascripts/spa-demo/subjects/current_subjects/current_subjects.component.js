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

      $scope.$watch(
        function(){ return currentSubjects.getImages(); }, 
        function(images) { 
          vm.images = images; 
          displaySubjects(); 
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
      displaySubjects();  
    }

    function displaySubjects(){
      if (!vm.map) { return; }
      vm.map.clearMarkers();
      vm.map.displayOriginMarker();

      angular.forEach(vm.images, function(ti){
        displaySubject(ti);
      });
    }

    function displaySubject(ti) {
      var markerOptions = {
        position: {
          lng: ti.position.lng,
          lat: ti.position.lat
        }
      };
      if (ti.thing_id && ti.priority===0) {
        markerOptions.title = ti.thing_name;
        markerOptions.icon = APP_CONFIG.thing_marker;
      } else if (ti.thing_id) {
        markerOptions.title = ti.thing_name;
        markerOptions.icon = APP_CONFIG.secondary_marker;
      } else {
        markerOptions.title = ti.image_caption;
        markerOptions.icon = APP_CONFIG.orphan_marker;
      }
      vm.map.displayMarker(markerOptions);    
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
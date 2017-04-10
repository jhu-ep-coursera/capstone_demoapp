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
      $scope.$watch(
        function(){ return currentSubjects.getCurrentImage(); }, 
        function(link) { 
          if (link) { 
            vm.setActiveMarker(link.thing_id, link.image_id); 
          } else {
            vm.setActiveMarker(null,null);           
          }
        }); 
      $scope.$watch(
        function(){ 
            return vm.map ? vm.map.getCurrentMarker() : null; }, 
        function(marker) { 
          if (marker) {
            console.log("map changed markers", marker);
            currentSubjects.setCurrentSubjectId(marker.thing_id, marker.image_id);
          }
        }); 
      $scope.$watch(
        function() { return currentOrigin.getLocation(); },
        function(location) { 
          vm.location = location;
          vm.updateOrigin(); 
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
      vm.map.displayOriginMarker(vm.originInfoWindow(vm.location));

      angular.forEach(vm.images, function(ti){
        displaySubject(ti);
      });
    }

    function displaySubject(ti) {
      var markerOptions = {
        position: {
          lng: ti.position.lng,
          lat: ti.position.lat
        },
        thing_id: ti.thing_id,
        image_id: ti.image_id          
      };
      if (ti.thing_id && ti.priority===0) {
        markerOptions.title = ti.thing_name;
        markerOptions.icon = APP_CONFIG.thing_marker;
        markerOptions.content = vm.thingInfoWindow(ti);
      } else if (ti.thing_id) {
        markerOptions.title = ti.thing_name;
        markerOptions.icon = APP_CONFIG.secondary_marker;
        markerOptions.content = vm.thingInfoWindow(ti);
      } else {
        markerOptions.title = ti.image_caption;
        markerOptions.icon = APP_CONFIG.orphan_marker;
        markerOptions.content = vm.imageInfoWindow(ti);
      }
      vm.map.displayMarker(markerOptions);    
    }
  }

  CurrentSubjectsMapController.prototype.updateOrigin = function() {
    if (this.map && this.location) {
      this.map.center({ 
        center: this.location.position
      });
      this.map.displayOriginMarker(this.originInfoWindow(this.location));
    }
  }

  CurrentSubjectsMapController.prototype.setActiveMarker = function(thing_id, image_id) {
    if (!this.map) { 
      return; 
    } else if (!thing_id && !image_id) {
      if (this.map.getCurrentMarker().title!=='origin') {
        this.map.setActiveMarker(null);
      }
    } else {
      var markers=this.map.getMarkers();
      for (var i=0; i<markers.length; i++) {
        var marker=markers[i];
        if (marker.thing_id === thing_id && marker.image_id === image_id) {
            this.map.setActiveMarker(marker);
            break;
        }
      }
    } 
  }

  CurrentSubjectsMapController.prototype.originInfoWindow = function(location) {
    console.log("originInfo", location);
    var full_address = location ? location.formatted_address : "";
    var lng = location && location.position ? location.position.lng : "";
    var lat = location && location.position ? location.position.lat : "";
    var html = [
      "<div class='origin'>",
        "<div class='full_address'>"+ full_address + "</div>",
        "<div class='position'>",
          "lng: <span class='lng'>"+ lng +"</span>",
          "lat: <span class='lat'>"+ lat +"</span>",
        "</div>",
      "</div>",
    ].join("\n");

    return html;
  }

  CurrentSubjectsMapController.prototype.thingInfoWindow = function(ti) {
    console.log("thingInfo", ti);
    var html ="<div class='thing-marker-info'><div>";
      html += "<span class='id ti_id'>"+ ti.id+"</span>";
      html += "<span class='id thing_id'>"+ ti.thing_id+"</span>";
      html += "<span class='id image_id'>"+ ti.image_id+"</span>";
      html += "<span class='thing-name'>"+ ti.thing_name + "</span>";
      if (ti.image_caption) {
        html += "<span class='image-caption'> ("+ ti.image_caption + ")</span>";      
      }
      if (ti.distance) {
        html += "<span class='distance'> ("+ Number(ti.distance).toFixed(1) +" mi)</span>";
      }
      html += "</div><img src='"+ ti.image_content_url+"?width=200'>";
      html += "</div>";
    return html;
  }

  CurrentSubjectsMapController.prototype.imageInfoWindow = function(ti) {
    console.log("imageInfo", ti);
    var html ="<div class='image-marker-info'><div>";
      html += "<span class='id image_id'>"+ ti.image_id+"</span>";
      if (ti.image_caption) {
        html += "<span class='image-caption'>"+ ti.image_caption + "</span>";      
      }
      if (ti.distance) {
        html += "<span class='distance'> ("+ Number(ti.distance).toFixed(1) +" mi)</span>";
      }
      html += "</div><img src='"+ ti.image_content_url+"?width=200'>";
      html += "</div>";
    return html;    
  }


})();

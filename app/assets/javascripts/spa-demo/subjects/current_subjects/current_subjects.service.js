(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .service("spa-demo.subjects.currentSubjects", CurrentSubjects);

  CurrentSubjects.$inject = ["$rootScope",
                             "$resource",
                             "spa-demo.geoloc.currentOrigin",
                             "spa-demo.config.APP_CONFIG"];

  function CurrentSubjects($rootScope, $resource, currentOrigin, APP_CONFIG) {
    var subjectsResource = $resource(APP_CONFIG.server_url + "/api/subjects",{},{});
    var service = this;
    service.version = 0;
    service.images = [];
    service.imageIdx = null;
    service.things = [];
    service.thingIdx = null;
    service.refresh = refresh;
    service.isCurrentImageIndex = isCurrentImageIndex;
    service.isCurrentThingIndex = isCurrentThingIndex;

    //refresh();
    $rootScope.$watch(function(){ return currentOrigin.getVersion(); }, refresh);
    return;
    ////////////////
    function refresh() {      
      var params=currentOrigin.getPosition();
      if (!params || !params.lng || !params.lat) {
        params=angular.copy(APP_CONFIG.default_position);
      } else {
        params["distance"]=true;
      }

      if (currentOrigin.getDistance() > 0) {
        params["miles"]=currentOrigin.getDistance();
      }
      params["order"]="ASC";
      console.log("refresh",params);

      refreshImages(params);
      params["subject"]="thing";      
      refreshThings(params);
    }

    function refreshImages(params) {
      subjectsResource.query(params).$promise.then(
        function(images){
          service.images=images;
          service.version += 1;
          if (!service.imageIdx || service.imageIdx > images.length) {
            service.imageIdx=0;
          }
          console.log("refreshImages", service);
        });
    }
    function refreshThings(params) {
      subjectsResource.query(params);
      //...
    }

    function isCurrentImageIndex(index) {
      //console.log("isCurrentImageIndex", index, service.imageIdx === index);
      return service.imageIdx === index;
    }
    function isCurrentThingIndex(index) {
      //console.log("isCurrentThingIndex", index, service.thingIdx === index);
      return service.thingIdx === index;
    }
  }

  CurrentSubjects.prototype.getVersion = function() {
    return this.version;
  }
  CurrentSubjects.prototype.getImages = function() {
    return this.images;
  }
  CurrentSubjects.prototype.getThings = function() {
    return this.things;
  }
  CurrentSubjects.prototype.getCurrentImage = function() {
    return this.images.length > 0 ? this.images[this.imageIdx] : null;
  }
  CurrentSubjects.prototype.getCurrentThing = function() {
    return this.things.length > 0 ? this.things[this.thingIdx] : null;
  }


  CurrentSubjects.prototype.setCurrentImage = function(index) {
    if (index >= 0 && this.images.length > 0) {
      this.imageIdx = (index < this.images.length) ? index : 0;
    } else if (index < 0 && this.images.length > 0) {
      this.imageIdx = this.images.length - 1;
    } else {
      this.imageIdx = null;
    }

    console.log("setCurrentImage", this.imageIdx, this.getCurrentImage());
    return this.getCurrentImage();
  }

  CurrentSubjects.prototype.setCurrentThing = function(index) {
    if (index >= 0 && this.things.length > 0) {
      this.thingIdx = (index < this.things.length) ? index : 0;
    } else if (index < 0 && this.things.length > 0) {
      this.thingIdx = this.things.length - 1;
    } else {
      this.thingIdx=null;
    }

    console.log("setCurrentThing", this.thingIdx, this.getCurrentThing());
    return this.getCurrentThing();
  }

})();

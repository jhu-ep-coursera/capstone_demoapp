(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .service("spa-demo.subjects.currentSubjects", CurrentSubjects);

  CurrentSubjects.$inject = ["$rootScope","$q",
                             "$resource",
                             "spa-demo.geoloc.currentOrigin",
                             "spa-demo.config.APP_CONFIG"];

  function CurrentSubjects($rootScope, $q, $resource, currentOrigin, APP_CONFIG) {
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
    service.nextThing = nextThing;
    service.previousThing = previousThing;

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

      var p1=refreshImages(params);
      params["subject"]="thing";      
      var p2=refreshThings(params);
      $q.all([p1,p2]).then(
        function(){
          service.setCurrentImageForCurrentThing();
        });      
    }

    function refreshImages(params) {
      var result=subjectsResource.query(params);
      result.$promise.then(
        function(images){
          service.images=images;
          service.version += 1;
          if (!service.imageIdx || service.imageIdx > images.length) {
            service.imageIdx=0;
          }
          console.log("refreshImages", service);
        });
      return result.$promise;
    }
    function refreshThings(params) {
      var result=subjectsResource.query(params);
      result.$promise.then(
        function(things){
          service.things=things;
          service.version += 1;
          if (!service.thingIdx || service.thingIdx > things.length) {
            service.thingIdx=0;
          }
          console.log("refreshThings", service);
        });
      return result.$promise;
    }

    function isCurrentImageIndex(index) {
      //console.log("isCurrentImageIndex", index, service.imageIdx === index);
      return service.imageIdx === index;
    }
    function isCurrentThingIndex(index) {
      //console.log("isCurrentThingIndex", index, service.thingIdx === index);
      return service.thingIdx === index;
    }
    function nextThing() {
      if (service.thingIdx !== null) {
        service.setCurrentThing(service.thingIdx + 1);
      } else if (service.things.length >= 1) {
        service.setCurrentThing(0);
      }    
    }
    function previousThing() {
      if (service.thingIdx !== null) {
        service.setCurrentThing(service.thingIdx - 1);
      } else if (service.things.length >= 1) {
        service.setCurrentThing(service.things.length-1);
      }
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
  CurrentSubjects.prototype.getCurrentImageIndex = function() {
     return this.imageIdx;
  }
  CurrentSubjects.prototype.getCurrentImage = function() {
    return this.images.length > 0 ? this.images[this.imageIdx] : null;
  }
  CurrentSubjects.prototype.getCurrentThing = function() {
    return this.things.length > 0 ? this.things[this.thingIdx] : null;
  }


  CurrentSubjects.prototype.setCurrentImage = function(index, skipThing) {
    if (index >= 0 && this.images.length > 0) {
      this.imageIdx = (index < this.images.length) ? index : 0;
    } else if (index < 0 && this.images.length > 0) {
      this.imageIdx = this.images.length - 1;
    } else {
      this.imageIdx = null;
    }

    if (!skipThing) {
      this.setCurrentThingForCurrentImage();
    }

    console.log("setCurrentImage", this.imageIdx, this.getCurrentImage());
    return this.getCurrentImage();
  }

  CurrentSubjects.prototype.setCurrentThing = function(index, skipImage) {
    if (index >= 0 && this.things.length > 0) {
      this.thingIdx = (index < this.things.length) ? index : 0;
    } else if (index < 0 && this.things.length > 0) {
      this.thingIdx = this.things.length - 1;
    } else {
      this.thingIdx=null;
    }

    if (!skipImage) {
      this.setCurrentImageForCurrentThing();
    }

    console.log("setCurrentThing", this.thingIdx, this.getCurrentThing());
    return this.getCurrentThing();
  }

  CurrentSubjects.prototype.setCurrentThingForCurrentImage = function() {
    var image=this.getCurrentImage();
    if (!image || !image.thing_id) {
      this.thingIdx = null;
    } else {
      var thing=this.getCurrentThing();
      if (!thing || thing.thing_id !== image.thing_id) {
        this.thingIdx=null;
        for (var i=0; i<this.things.length; i++) {
          thing=this.things[i];
          if (image.thing_id === thing.thing_id) {
            this.setCurrentThing(i, true);
            break;
          }
        }
      }      
    }
  }

  CurrentSubjects.prototype.setCurrentImageForCurrentThing = function() {
    var image=this.getCurrentImage();
    var thing=this.getCurrentThing();
    if (!thing) {
      this.imageIdx=null;
    } else if ((thing && thing.thing_id !== image.thing_id) || !image || image.priority!==0) {
      for (var i=0; i<this.images.length; i++) {
        image=this.images[i];
        if (image.thing_id === thing.thing_id && image.priority===0) {
          this.setCurrentImage(i, true);
          break;
        }
      }
    }
  }
















  })();

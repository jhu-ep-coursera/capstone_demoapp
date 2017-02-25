(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .component("sdImageViewer", {
      templateUrl: templateUrl,
      controller: ImageViewerController,
      bindings: {
        name: "@",
        images: "<",
        minWidth: "@"
      },
    });

  templateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function templateUrl(APP_CONFIG) {
    return APP_CONFIG.image_viewer_html;
  }    

  ImageViewerController.$inject = ["$scope", "$element","spa-demo.layout.ImageQuerySize"];
  function ImageViewerController($scope, $element,ImageQuerySize) {
    var sizing=null;
    var vm=this;
    vm.imageUrl=imageUrl;
    vm.imageId=imageId;    
    vm.imageCaption=imageCaption;
    vm.isCurrentIndex=isCurrentIndex;
    vm.previousImage=previousImage;
    vm.nextImage=nextImage;

    vm.$onInit = function() {
      vm.currentIndex = 0;      
      console.log(vm.name, "ImageViewerController", $scope);
    }
    vm.$postLink = function() {
      sizing=new ImageQuerySize($element.find('div'), this.minWidth);
      vm.queryString=sizing.queryString();
      sizing.listen(resizeHandler);      
    }        
    vm.$onDestroy = function() {
      sizing.nolisten(resizeHandler);
    }
    return;
    //////////////
    function resizeHandler(event) { 
      console.log("window resized");
      if (sizing.updateSizes(vm.minWidth)) {
        vm.queryString=sizing.queryString();
        console.log("new query size", vm.queryString);
        $scope.$apply();
      }
    }
    function isCurrentIndex(index) {
      return index === vm.currentIndex;
    }
    function nextImage() {
      setCurrentIndex(vm.currentIndex+1);
    }
    function previousImage() {
      setCurrentIndex(vm.currentIndex-1);
    }
    function setCurrentIndex(index) {
      console.log("setCurrentIndex", vm.name, index);
      if (vm.images && vm.images.length > 0) {
        if (index >= vm.images.length) {
          vm.currentIndex=0;
        } else if (index < 0) {
          vm.currentIndex=vm.images.length-1;
        } else {
          vm.currentIndex=index;
        }
      } else {
        vm.currentIndex=0;
      }
    }

    function imageCaption(object) {
      if (!object) { return null; }
      var caption = object.image_id ? object.image_caption : object.caption;
      return caption;
    }

    function imageUrl(object) {
      if (!object) { return null; }
      var url = object.image_id ? object.image_content_url : object.content_url;
      url += vm.queryString;
      console.log(vm.name, "url=", url);
      return url;
    }
    function imageId(object) {
      if (!object) { return null }
      var id = object.image_id ? object.image_id : object.id;
      return id; 
    }  
  }
})();
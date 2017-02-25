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
      },
    });

  templateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function templateUrl(APP_CONFIG) {
    return APP_CONFIG.image_viewer_html;
  }    

  ImageViewerController.$inject = ["$scope"];
  function ImageViewerController($scope) {
    var vm=this;
    vm.imageUrl=imageUrl;
    vm.imageId=imageId;    
    vm.isCurrentIndex=isCurrentIndex;

    vm.$onInit = function() {
      vm.currentIndex = 0;      
      console.log(vm.name, "ImageViewerController", $scope);
    }
    return;
    //////////////
    function isCurrentIndex(index) {
      return index === vm.currentIndex;
    }

    function imageUrl(object) {
      if (!object) { return null; }
      var url = object.image_id ? object.image_content_url : object.content_url;
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
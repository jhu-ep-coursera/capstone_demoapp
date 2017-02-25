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

    vm.$onInit = function() {
      console.log(vm.name, "ImageViewerController", $scope);
    }
    return;
    //////////////
  }
})();
(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdCurrentImages", {
      templateUrl: imagesTemplateUrl,
      controller: CurrentImagesController,
    })
    .component("sdCurrentImageViewer", {
      templateUrl: imageViewerTemplateUrl,
      controller: CurrentImageViewerController,
      bindings: {
        name: "@",
        minWidth: "@"
      }
    })
    ;

  imagesTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function imagesTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.current_images_html;
  }    
  imageViewerTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function imageViewerTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.current_image_viewer_html;
  }    

  CurrentImagesController.$inject = ["$scope",
                                     "spa-demo.subjects.currentSubjects"];
  function CurrentImagesController($scope, currentSubjects) {
    var vm=this;
    vm.imageClicked = imageClicked;
    vm.isCurrentImage = currentSubjects.isCurrentImageIndex;

    vm.$onInit = function() {
      console.log("CurrentImagesController",$scope);
    }
    vm.$postLink = function() {
      $scope.$watch(
        function() { return currentSubjects.getImages(); }, 
        function(images) { vm.images = images; }
      );
    }    
    return;
    //////////////
    function imageClicked(index) {
      currentSubjects.setCurrentImage(index);
    }
  }

  CurrentImageViewerController.$inject = ["$scope",
                                          "spa-demo.subjects.currentSubjects"];
  function CurrentImageViewerController($scope, currentSubjects) {
    var vm=this;
    vm.viewerIndexChanged = viewerIndexChanged;

    vm.$onInit = function() {
      console.log("CurrentImageViewerController",$scope);
    }
    vm.$postLink = function() {
      $scope.$watch(
        function() { return currentSubjects.getImages(); }, 
        function(images) { vm.images = images; }
      );
      $scope.$watch(
        function() { return currentSubjects.getCurrentImageIndex(); }, 
        function(index) { vm.currentImageIndex = index; }
      );
    }    
    return;
    //////////////
    function viewerIndexChanged(index) {
      console.log("viewer index changed, setting currentImage", index);
      currentSubjects.setCurrentImage(index);
    }
  }

})();

(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdCurrentImages", {
      templateUrl: imagesTemplateUrl,
      controller: CurrentImagesController,
    });


  imagesTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function imagesTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.current_images_html;
  }    

  CurrentImagesController.$inject = ["$scope",
                                     "spa-demo.subjects.currentSubjects"];
  function CurrentImagesController($scope, currentSubjects) {
    var vm=this;

    vm.$onInit = function() {
      console.log("CurrentImagesController",$scope);
    }
    return;
    //////////////
  }
})();
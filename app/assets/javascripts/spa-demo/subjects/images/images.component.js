(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdImageSelector", {
      templateUrl: imageSelectorTemplateUrl,
      controller: ImageSelectorController,
      bindings: {},
    })
    .component("sdImageEditor", {
      templateUrl: imageEditorTemplateUrl,
      controller: ImageEditorController,
      bindings: {},
    });


  imageSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function imageSelectorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.image_selector_html;
  }    
  imageEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function imageEditorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.image_editor_html;
  }    

  ImageSelectorController.$inject = ["$scope",
                                     "$stateParams",
                                     "spa-demo.subjects.Image"];
  function ImageSelectorController($scope, $stateParams, Image) {
    var vm=this;

    vm.$onInit = function() {
      console.log("ImageSelectorController",$scope);
      if (!$stateParams.id) {
        vm.items = Image.query();
      }
    }
    return;
    //////////////
  }


  ImageEditorController.$inject = ["$scope",
                                   "$stateParams",
                                   "spa-demo.subjects.Image"];
  function ImageEditorController($scope, $stateParams, Image) {
    var vm=this;

    vm.$onInit = function() {
      console.log("ImageEditorController",$scope);
      if ($stateParams.id) {
        vm.item = Image.get({id:$stateParams.id});
      } else {
        newResource();
      }
    }
    return;
    //////////////
    function newResource() {
      vm.item = new Image();
      return vm.item;
    }
  }

})();
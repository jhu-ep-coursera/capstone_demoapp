(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdImageSelector", {
      templateUrl: imageSelectorTemplateUrl,
      controller: ImageSelectorController,
      bindings: {
        authz: "<"
      },
    })
    .component("sdImageEditor", {
      templateUrl: imageEditorTemplateUrl,
      controller: ImageEditorController,
      bindings: {
        authz: "<"
      },
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


  ImageEditorController.$inject = ["$scope","$q",
                                   "$state", "$stateParams",
                                   "spa-demo.subjects.Image",
                                   "spa-demo.subjects.ImageThing",
                                   "spa-demo.subjects.ImageLinkableThing",
                                   ];
  function ImageEditorController($scope, $q, $state, $stateParams, 
                                 Image, ImageThing,ImageLinkableThing) {
    var vm=this;
    vm.create = create;
    vm.clear  = clear;
    vm.update  = update;
    vm.remove  = remove;

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

    function clear() {
      newResource();
      $state.go(".", {id:null});
    }

    function create() {
      $scope.imageform.$setPristine();
      vm.item.errors = null;
      vm.item.$save().then(
        function(){
           $state.go(".", {id: vm.item.id}); 
        },
        handleError);
    }

    function update() {
      $scope.imageform.$setPristine();
      vm.item.errors = null;
      vm.item.$update().then(
        function(){ 
          console.log("update complete", vm.item);
          $state.reload(); 
        },
        handleError);      
    }

    function remove() {
      vm.item.errors = null;
      vm.item.$delete().then(
        function(){ 
          console.log("remove complete", vm.item);          
          clear();
        },
        handleError);      
    }


    function handleError(response) {
      //console.log("error", response);
      if (response.data) {
        vm.item["errors"]=response.data.errors;          
      } 
      if (!vm.item.errors) {
        vm.item["errors"]={}
        vm.item["errors"]["full_messages"]=[response]; 
      }      
    }    
  }

})();
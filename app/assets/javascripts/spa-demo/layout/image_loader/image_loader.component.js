(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .component("sdImageLoader", {
      templateUrl: templateUrl,
      controller: ImageLoaderController,
      bindings: {
        resultDataUri: "&"        
      },
      transclude: true
    });


  templateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function templateUrl(APP_CONFIG) {
    return APP_CONFIG.image_loader_html;
  }    

//  ImageLoaderController.$inject = ["$scope","UploadDataUrl"];
//  function ImageLoaderController($scope, UploadDataUrl) {
  
  ImageLoaderController.$inject = ["$scope"];
  function ImageLoaderController($scope) {
    var vm=this;
    vm.debug=debug;

    vm.$onInit = function() {
      console.log("ImageLoaderController",$scope);
      $scope.$watch(function(){ return vm.dataUri }, 
                    function(){ vm.resultDataUri({dataUri: vm.dataUri}); });      
      // $scope.$watch(function(){ return vm.file }, 
      //               function(){ makeObjectUrl(); makeDataUri(); });      
    }
    return;
    //////////////
    // function makeDataUri() {
    //   vm.dataUri=null;
    //   if (vm.file) {
    //     UploadDataUrl.dataUrl(vm.file, true).then(
    //       function(dataUri){
    //         vm.dataUri = dataUri;
    //         console.log("created dataUri", vm.file, vm.dataUri.length);
    //         vm.resultDataUri({dataUri: vm.dataUri})
    //       });
    //   }
    // }

    // function makeObjectUrl() {
    //   vm.objectUrl = null;      
    //   if (vm.file) {
    //     UploadDataUrl.dataUrl(vm.file, false).then(
    //       function(objectUrl){
    //         vm.objectUrl = objectUrl;
    //         console.log("created objectURL", vm.file, vm.objectUrl);            
    //       });
    //   }      
    // }
    function debug() {
      console.log("ImageLoaderController",$scope);      
    }
  }
})();

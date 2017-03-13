(function() {
  "use strict";

  angular
    .module("spa-demo.geoloc")
    .component("sdCurrentOriginSelector", {
      templateUrl: templateUrl,
      controller: CurrentOriginSelectorController,
      //bindings: {},
    });


  templateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function templateUrl(APP_CONFIG) {
    return APP_CONFIG.current_origin_selector_html;
  }    

  CurrentOriginSelectorController.$inject = ["$scope"];
  function CurrentOriginSelectorController($scope) {
    var vm=this;

    vm.$onInit = function() {
      console.log("CurrentOriginSelectorController",$scope);
    }
    return;
    //////////////
  }
})();
(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .component("sdAreas", {
      templateUrl: areasTemplateUrl,
      controller: AreasController,
      transclude: true,
      //bindings: {},
    })
    .component("sdArea", {
      templateUrl: areaTemplateUrl,
      controller: AreaController,
      transclude: true,
      bindings: {
        label: "@"
      },
      require: {
        areasController: "^^sdAreas"
      }
    })
    ;

  areasTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function areasTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.areas_html;
  }    
  areaTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function areaTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.area_html;
  }    

  AreasController.$inject = ["$scope"];
  function AreasController($scope) {
    var vm=this;
    vm.areas=[];

    vm.$onInit = function() {
      console.log("AreasController",$scope);
    }
    return;
    //////////////
  }
  AreasController.prototype.addArea = function(area) {
    this.areas.push(area);
  }  


  AreaController.$inject = ["$scope"];
  function AreaController($scope) {
    var vm=this;
    vm.show=true;

    vm.$onInit = function() {
      console.log("AreaController",$scope);
      vm.areasController.addArea(vm);
    }
    return;
    //////////////
  }

})();
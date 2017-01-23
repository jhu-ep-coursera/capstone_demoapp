(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdThingEditor", {
      templateUrl: thingEditorTemplateUrl,
      controller: ThingEditorController,
      bindings: {
        authz: "<"
      }
    })
    .component("sdThingSelector", {
      templateUrl: thingSelectorTemplateUrl,
      controller: ThingSelectorController,
      bindings: {
        authz: "<"
      }
    })
    ;


  thingEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function thingEditorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.thing_editor_html;
  }    
  thingSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function thingSelectorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.thing_selector_html;
  }    

  ThingEditorController.$inject = ["$scope","$q",
                                   "$state","$stateParams",
                                   "spa-demo.subjects.Thing",
                                   "spa-demo.subjects.ThingImage"];
  function ThingEditorController($scope, $q, $state, $stateParams, 
                                 Thing, ThingImage) {
    var vm=this;
    vm.create = create;
    vm.clear  = clear;
    vm.update  = update;
    vm.remove  = remove;

    vm.$onInit = function() {
      console.log("ThingEditorController",$scope);
      if ($stateParams.id) {
        reload($stateParams.id);
      } else {
        newResource();
      }
    }

    return;
    //////////////
    function newResource() {
      vm.item = new Thing();
      return vm.item;
    }

    function reload(thingId) {
      var itemId = thingId ? thingId : vm.item.id;      
      console.log("re/loading thing", itemId);
      vm.images = ThingImage.query({thing_id:itemId});
      vm.item = Thing.get({id:itemId});
      vm.images.$promise.then(
        function(){
          angular.forEach(vm.images, function(ti){
            ti.originalPriority = ti.priority;            
          });                     
        });
      $q.all([vm.item.$promise,vm.images.$promise]).catch(handleError);
    }

    function create() {      
      $scope.thingform.$setPristine();
      vm.item.errors = null;
      vm.item.$save().then(
        function(){
          console.log("thing created", vm.item);
          $state.go(".",{id:vm.item.id});
        },
        handleError);
    }

    function clear() {
      newResource();
      $state.go(".",{id: null});    
    }
    function update() {      
      $scope.thingform.$setPristine();
      vm.item.errors = null;
      vm.item.$update().then(
        function(){
          console.log("thing updated", vm.item);
          $state.reload();
        },
        handleError);
    }

    function remove() {      
      vm.item.$remove().then(
        function(){
          console.log("thing.removed", vm.item);
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

  ThingSelectorController.$inject = ["$scope",
                                     "$stateParams",
                                     "spa-demo.subjects.Thing"];
  function ThingSelectorController($scope, $stateParams, Thing) {
    var vm=this;

    vm.$onInit = function() {
      console.log("ThingSelectorController",$scope);
      if (!$stateParams.id) {
        vm.items = Thing.query();        
      }
    }
    return;
    //////////////
  }

})();
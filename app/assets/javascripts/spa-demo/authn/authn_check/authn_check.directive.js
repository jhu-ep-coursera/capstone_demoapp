(function() {
  "use strict";

  angular
    .module("spa-demo.authn")
    .directive("sdAuthnCheck", AuthnCheck);

  AuthnCheck.$inject = [];
  function AuthnCheck() {
    var directive = {
        bindToController: true,
        controller: AuthnCheckController,
        controllerAs: "idVM",
        restrict: "A",
        scope: false,
        link: link
    };
    return directive;

    function link(scope, element, attrs) {
      console.log("AuthnCheck",scope);
    }
  }

  AuthnCheckController.$inject = ["$auth", 
                                  "spa-demo.authn.whoAmI", 
                                  "spa-demo.authn.checkMe"];
  function AuthnCheckController($auth, whoAmI, checkMe) {
    var vm = this;
    vm.client = {}
    vm.server = {}
    vm.getClientUser = getClientUser;
    vm.whoAmI = getServerUser;
    vm.checkMe = checkServerUser;

    return;
    //////////////
    function getClientUser() {
      vm.client.currentUser = $auth.user;
    }
    function getServerUser() {
      vm.server.whoAmI = null;
      whoAmI.get().$promise.then(
        function(value){ vm.server.whoAmI = value; },
        function(value){vm.server.whoAmI = value; }
      );
    }
    function checkServerUser() {
      vm.server.checkMe = null;
      checkMe.get().$promise.then(
        function(value){ vm.server.checkMe = value; },
        function(value){ vm.server.checkMe = value; }
      );
    }
  }
})();
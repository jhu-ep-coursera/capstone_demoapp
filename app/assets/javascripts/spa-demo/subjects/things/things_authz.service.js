(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.ThingsAuthz", ThingsAuthzFactory);

  ThingsAuthzFactory.$inject = ["spa-demo.authz.Authz",
                                "spa-demo.authz.BasePolicy"];
  function ThingsAuthzFactory(Authz, BasePolicy) {
    function ThingsAuthz() {
      BasePolicy.call(this, "Thing");
    }
      //start with base class prototype definitions
    ThingsAuthz.prototype = Object.create(BasePolicy.prototype);
    ThingsAuthz.constructor = ThingsAuthz;


      //override and add additional methods
    ThingsAuthz.prototype.canQuery=function() {
      //console.log("ThingsAuthz.canQuery");
      return Authz.isAuthenticated();
    };

      //add custom definitions
    ThingsAuthz.prototype.canAddImage=function(thing) {
        return Authz.isMember(thing);
    };
    ThingsAuthz.prototype.canUpdateImage=function(thing) {
        return Authz.isOrganizer(thing)
    };
    ThingsAuthz.prototype.canRemoveImage=function(thing) {
        return Authz.isOrganizer(thing) || Authz.isAdmin();
    };
    
    return new ThingsAuthz();
  }
})();
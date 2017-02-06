(function() {
  "use strict";

  angular
    .module("spa-demo.authz")
    .factory("spa-demo.authz.BasePolicy", BasePolicyFactory);

  BasePolicyFactory.$inject = ["spa-demo.authz.Authz"];
  function BasePolicyFactory(Authz) {
    function BasePolicy(resourceName) {
      this.resourceName = resourceName;
      return;
    }

    BasePolicy.prototype.getAuthorizedUserId = function() {
      return Authz.getAuthorizedUserId();
    };
    //returns a promise of the user being resolved
    BasePolicy.prototype.getAuthorizedUser = function() {
      return Authz.getAuthorizedUser();
    }
    BasePolicy.prototype.isAuthenticated = function() {
      return Authz.isAuthenticated();
    }
    BasePolicy.prototype.canCreate = function() {
      //console.log("BasePolicy.canCreate");
      return Authz.isOriginator(this.resourceName);
    };
    BasePolicy.prototype.canQuery = function() {
      //console.log("BasePolicy.canQuery");
      return true;
    };
    BasePolicy.prototype.canUpdate = function(item) {
      //console.log("BasePolicy.canUpdate", item);
      if (!item) {
        return false;
      } else {
        return !item.id ? this.canCreate() : Authz.isOrganizer(item);
      }
    };
    BasePolicy.prototype.canDelete = function(item) {
      //console.log("BasePolicy.canDelete", item);
      return (item && item.id && (this.canUpdate(item) || Authz.isAdmin())) == true;
    };
    BasePolicy.prototype.canGetDetails = function(item) {
      //console.log("BasePolicy.canGetDetails", item);
      if (!item) {
        return false;
      } else {
        return !item.id ? this.canCreate() : (Authz.isMember(item) || Authz.isAdmin());
      }
    };
    return BasePolicy;
  }
})();
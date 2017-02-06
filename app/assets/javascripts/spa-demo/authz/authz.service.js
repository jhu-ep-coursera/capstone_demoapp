(function() {
  "use strict";

  angular
    .module("spa-demo.authz")
    .service("spa-demo.authz.Authz", Authz);

  Authz.$inject = ["$rootScope", "$q",
                   "spa-demo.authn.Authn",
                   "spa-demo.authn.whoAmI"];

  function Authz($rootScope, $q, Authn, whoAmI) {
    var service = this;
    service.user=null;        //holds result from server
    service.userPromise=null; //promise during server request
    service.admin=false;
    service.originator=[]

    service.getAuthorizedUser=getAuthorizedUser;
    service.getAuthorizedUserId=getAuthorizedUserId;
    service.isAuthenticated=isAuthenticated;
    service.isAdmin=isAdmin;
    service.isOriginator=isOriginator;
    service.isOrganizer=isOrganizer;
    service.isMember=isMember;
    service.hasRole=hasRole;

    activate();
    return;
    ////////////////
    function activate() {
      $rootScope.$watch(
        function(){ return Authn.getCurrentUserId(); },
        newUser);
    }

    function newUser() {
      //we do not have a authz-user until resolved
      var deferred=$q.defer();
      service.userPromise = deferred.promise;
      service.user=null;

      service.admin=false;
      service.originator=[];
      whoAmi.get().$promise.then(
        function(response){processUserRoles(response, deferred);},
        function(response){processUserRoles(response, deferred);});      
    }

    //process application-level roles returned from server
    function processUserRoles(response, deferred) {
      console.log("processing roles", service.state, response);
      angular.forEach(response.user_roles, function(value){
        if (value.role_name=="admin") {
          service.admin=true;
        } else if (value.role_name=="originator") {
          service.originator.push(value.resource);
        }          
      });      

      service.user=response;
      service.userPromise=null;
      deferred.resolve(response);
      console.log("processed roles", service.user);
    }    

    function getAuthorizedUser() {
      var deferred = $q.defer();

      var promise=service.userPromise;
      if (promise) {
        promise.then(
          function(){ deferred.resolve(service.user); },
          function(){ deferred.reject(service.user);  });
      } else {
        deferred.resolve(service.user);
      }

      return deferred.promise;
    }

    function getAuthorizedUserId() {
      return service.user && !service.userPromise ? service.user.id : null;
    }

    function isAuthenticated() {
      return getAuthorizedUserId()!=null;
    }

    //return true if the user has an application admin role
    function isAdmin() {
      return service.user && service.admin && true;
    }    

    //return true if the current user has an organizer role for the instance
    //users with this role have the lead when modifying the instance
    function isOriginator(resource) {
      return service.user && service.originator.indexOf(resource) >= 0;
    }

    //return true if the current user has an organizer role for the instance
    //users with this role have the lead when modifying the instance
    function isOrganizer(item) {
      return !item ? false : hasRole(item.user_roles, 'organizer');
    }

    //return true if the current user has a member role for the instance
    //users with this role are associated in a formal way with the instance
    //and may be able to make some modifications to the instance
    function isMember(item) {
      return !item ? false : hasRole(item.user_roles, 'member') || isOrganizer(item);
    }

    //return true if the collection of roles contains the specified role
    function hasRole(user_roles, role) {
      if (role) {
        return !user_roles ? false : user_roles.indexOf(role) >=0;
      } else {
        return !user_roles ? true : user_roles.length==0 
      }
    } 
  }
})();
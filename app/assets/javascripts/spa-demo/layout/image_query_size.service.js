(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .factory("spa-demo.layout.ImageQuerySize", ImageQuerySizeFactory);

  ImageQuerySizeFactory.$inject = ["$httpParamSerializer"];
  function ImageQuerySizeFactory($httpParamSerializer) {

    function ImageQuerySize(element, minWidth) {
      this.element = element;
      this.width   = null;
      this.height  = null;
    }

    //return complete query string
    ImageQuerySize.prototype.queryString = function() {
      var params={}
      if (this.width) {
        params.width=this.width;
      }
      if (this.height) {
        params.height=this.height;
      }
      return Object.keys(params).length==0 ? "" : "?" + $httpParamSerializer(params);
    }    

    /////
    return ImageQuerySize;
    /////
  }
})();
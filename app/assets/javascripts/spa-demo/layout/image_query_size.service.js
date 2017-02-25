(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .factory("spa-demo.layout.ImageQuerySize", ImageQuerySizeFactory);

  ImageQuerySizeFactory.$inject = ["$window","$httpParamSerializer"];
  function ImageQuerySizeFactory($window, $httpParamSerializer) {

    function ImageQuerySize(element, minWidth) {
      this.element = element;
      this.width   = null;
      this.height  = null;
      this.updateSizes(minWidth);
    }
    
    ImageQuerySize.prototype.updateSizes = function(minWidth) {
      var w = this.queryWidth(this.element.innerWidth());
      var h = this.queryHeight(this.element.innerHeight());
      var newSize = (w != this.width) || (h != this.height);
      if (newSize) {
        this.width=w;
        this.height=h;        
      }
      return newSize;
    }
    ImageQuerySize.prototype.listen = function(handler) {
      angular.element($window).on('resize', handler);
    }
    ImageQuerySize.prototype.nolisten = function(handler) {
      angular.element($window).off('resize', handler);
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

    //break width into supported size boundaries
    ImageQuerySize.prototype.queryWidth = function(width) {
      var queryWidth=1200;
      if (width <= 100) {
        queryWidth=100
      } else if (width <= 320) {
        queryWidth=320
      } else if (width <= 800) {
        queryWidth=800
      }
      return queryWidth;
    }

    //break height into supported size boundaries
    ImageQuerySize.prototype.queryHeight = function(height) {
      var queryHeight=800
      if (height <= 67) {
        queryHeight = 67
      } else if (height <= 213) {
        queryHeight = 213
      } else if (height <= 533) {
        queryHeight = 533
      }
      return queryHeight;
    }    

    /////
    return ImageQuerySize;
    /////
  }
})();
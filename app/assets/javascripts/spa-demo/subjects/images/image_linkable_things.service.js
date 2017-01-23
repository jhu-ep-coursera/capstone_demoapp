(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.ImageLinkableThing", ImageLinkableThing);

  ImageLinkableThing.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function ImageLinkableThing($resource, APP_CONFIG) {
    return $resource(APP_CONFIG.server_url + "/api/images/:image_id/linkable_things");
  }

})();
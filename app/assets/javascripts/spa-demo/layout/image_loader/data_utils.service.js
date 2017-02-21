(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .service("spa-demo.layout.DataUtils", DataUtils);

  DataUtils.$inject = [];

  function DataUtils() {
    var service = this;
    service.getContentFromDataUri=getContentFromDataUri;

    return;
    ////////////////
    function getContentFromDataUri(dataUri) {
      if (!dataUri) { return null; }

      //data:image/jpeg;base64,SGVsbG8sIFdvcmxkIQ%3D%3D
      var splitDataUri = dataUri.split(',');
      if (splitDataUri.length < 2 || splitDataUri[0].indexOf(';base64')<0) {
        return null;
      }

      var re = /^data:(.+);/;
      var image_content={}
      image_content.content_type=re.exec(splitDataUri[0])[1];
      image_content.content=splitDataUri[1];
      return image_content;
    }
  }
})();
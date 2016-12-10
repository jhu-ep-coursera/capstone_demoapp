"use strict";

var gulp = require('gulp');
//gulp flow control
var gulpif = require('gulp-if');
var sync = require('gulp-sync')(gulp);
//build tools
var del = require('del');
var debug = require('gulp-debug');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var replace = require('gulp-replace');
//dist minification
var useref = require('gulp-useref');
var uglify = require('gulp-uglify');
var cssMin = require('gulp-clean-css');
var htmlMin = require('gulp-htmlmin');
//runtime tools
var browserSync = require('browser-sync').create();


//where we place out source code
var srcPath =  "client/src";  
//where any processed code or vendor files gets placed for use in development
var buildPath = "client/build";
//location to place vendor files for use in development
var vendorBuildPath = buildPath + "/vendor";
//where the final web application is placed
var distPath = "public/client";
//location of our vendor packages
var bowerPath = "bower_components";

var cfg={
  //our client application source code src globs and build paths
  root_html : { src: srcPath + "/index.html",   bld: buildPath },
  css :       { src: srcPath + "/stylesheets/**/*.css", bld: buildPath + "/stylesheets" },
  js :        { src: srcPath + "/javascripts/**/*.js" },
  html :      { src: [srcPath + "/**/*.html", "!"+srcPath + "/*.html"]}, 
  
  //vendor css src globs
  bootstrap_sass:     { src: bowerPath + "/bootstrap-sass/assets/stylesheets/" },

  //vendor fonts src globs
  bootstrap_fonts:   { src: bowerPath + "/bootstrap-sass/assets/fonts/**/*" },

  //vendor js src globs
  jquery:            { src: bowerPath + "/jquery2/jquery.js" },
  bootstrap_js:      { src: bowerPath + "/bootstrap-sass/assets/javascripts/bootstrap.js" },
  angular:           { src: bowerPath + "/angular/angular.js" },
  angular_ui_router: { src: bowerPath + "/angular-ui-router/release/angular-ui-router.js" },
  angular_resource:  { src: bowerPath + "/angular-resource/angular-resource.js" },   

  //vendor build locations 
  vendor_js :    { bld: vendorBuildPath + "/javascripts" },
  vendor_css :   { bld: vendorBuildPath + "/stylesheets" },
  vendor_fonts : { bld: vendorBuildPath + "/stylesheets/fonts" }, 

  apiUrl: { dev: "http://localhost:3000",
            prd: "https://glacial-earth-69618.herokuapp.com"},
};

//files within these paths will be served as root-level resources in this priority order
var devResourcePath = [
    cfg.vendor_js.bld,
    cfg.vendor_css.bld,
    buildPath+"/javascripts",
    buildPath+"/stylesheets",
    srcPath,
    srcPath+"/javascripts",
    srcPath+"/stylesheets",
    ];    

//remove all files below the build area
gulp.task("clean:build", function() {
  return del(buildPath);
});

//remove all files below the dist area
gulp.task("clean:dist", function() {
  return del(distPath);
});

//remove all files below both the build and dist area
gulp.task("clean", ["clean:build", "clean:dist"]);


//place vendor css files in build area
gulp.task("vendor_css", function(){
  return gulp.src([
          //cfg.bootstrap_css.src,
        ])
        .pipe(gulp.dest(cfg.vendor_css.bld));
});

//place vendor js files in build area
gulp.task("vendor_js", function(){
  return gulp.src([
          cfg.jquery.src,
          cfg.bootstrap_js.src,
          cfg.angular.src,
          cfg.angular_ui_router.src,
          cfg.angular_resource.src,
        ])
        .pipe(gulp.dest(cfg.vendor_js.bld));
});

//place vendor font files in build area
gulp.task('vendor_fonts', function() {
  //access the following font files
  return gulp.src([
          cfg.bootstrap_fonts.src,
      ])
      .pipe(gulp.dest(cfg.vendor_fonts.bld));
});

gulp.task('css', function() {
  return gulp.src(cfg.css.src).pipe(debug())
      .pipe(sourcemaps.init())
      .pipe(sass({ includePaths: [cfg.bootstrap_sass.src] }))
      .pipe(sourcemaps.write("./maps"))
      .pipe(gulp.dest(cfg.css.bld)).pipe(debug());
});

//prepare the development area
gulp.task("build", sync.sync(["clean:build", ["vendor_css", "vendor_js", "vendor_fonts", "css"]]));


//helper method to launch server and to watch for changes
function browserSyncInit(baseDir, watchFiles) {
  browserSync.instance = browserSync.init(watchFiles, {
    server: { baseDir: baseDir },
    port:   8080,
    ui:     { port: 8090 }
  });
};

//run the browser against the development/build area and watch files being edited
gulp.task("browserSync", ["build"], function() {
  browserSyncInit(devResourcePath,[
      cfg.root_html.src,
      cfg.css.bld + "/**/*.css",
      cfg.js.src,
      cfg.html.src,
    ]);
});

//prepare the development environment, launch server, and watch for changes
gulp.task("run", ["build", "browserSync"], function (){
  //extensions to watch() within even if we need to pre-process source code
  gulp.watch(cfg.css.src, ["css"]);
});


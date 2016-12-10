"use strict";

var gulp = require('gulp');

gulp.task("hello", function() {
  console.log("hello");
});

gulp.task("world", ["hello"], function() {
  console.log("world");
});

gulp.task("default", ["world"]);
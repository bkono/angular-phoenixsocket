# Utilities
gulp       = require("gulp")
gutil      = require("gulp-util")
gulpif     = require('gulp-if')
clean      = require("gulp-clean")
concat     = require("gulp-concat")
coffee     = require("gulp-coffee")
uglify     = require("gulp-uglify")
minifyCSS  = require("gulp-minify-css")
ngAnnotate = require "gulp-ng-annotate"
ngmin      = require("gulp-ngmin")
sass       = require("gulp-sass")
notify     = require("gulp-notify")
rename     = require("gulp-rename")

packageFileName = 'angular-phoenixsocket'

paths =
  scripts: ["src/**/*.{coffee,js}"]
  styles:  ["src/**/*.{scss,sass}"]

gulp.task "scripts", ->
  gulp.src paths.scripts
    .pipe(gulpif(/[.]coffee$/,
      coffee({bare:true})
      .on('error', gutil.log)
    ))
    .pipe(ngAnnotate())
    .pipe(concat("#{packageFileName}.js"))
    .pipe(gulp.dest("dist"))
    .pipe(uglify())
    .pipe(rename({extname: ".min.js"}))
    .pipe(gulp.dest("dist"))

gulp.task "styles", ->
  gulp.src paths.styles
    .pipe(sass({
        sourcemap: false,
        unixNewlines: true,
        style: 'nested',
        debugInfo: false,
        quiet: false,
        lineNumbers: true,
        bundleExec: true
      })
      .on('error', gutil.log))
      .on('error', notify.onError((error) ->
        return "SCSS Compilation Error: " + error.message;
      ))
    .pipe(rename("#{packageFileName}.css"))
    .pipe(gulp.dest("dist"))
    .pipe(minifyCSS())
    .pipe(rename({extname: ".min.css"}))
    .pipe(gulp.dest("dist"))

gulp.task "clean", ->
  return gulp.src(["dist"], {read: false})
    .pipe(clean({force: true}))

gulp.task 'watch', ->
  gulp.watch [paths.scripts], ['scripts']
  gulp.watch [paths.styles], ['styles']

gulp.task "compile", ["clean"], ->
  gulp.start("scripts", "styles")

gulp.task "default", ["clean"], ->
  gulp.start("scripts", "styles", "watch")

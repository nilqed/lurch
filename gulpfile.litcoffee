
# Build processes using [Gulp](http://gulpjs.com)

Load Gulp modules.

    gulp = require 'gulp' # main tool
    shell = require 'gulp-shell' # run external commands
    coffee = require 'gulp-coffee' # compile coffeescript
    uglify = require 'gulp-uglify' # minify javascript
    sourcemaps = require 'gulp-sourcemaps' # create source maps
    pump = require 'pump' # good error handling of gulp pipes
    concat = require 'gulp-concat' # for uniting source files

Create a task to concatenate all the source code files that make up the
Lurch Web Platform.

    gulp.task 'lwp-source', -> pump [
        gulp.src [
            'source/modules/utils.litcoffee'
            'source/modules/domutils.litcoffee'
            'source/modules/canvasutils.litcoffee'
            'source/plugins/*.litcoffee'
            'source/auxiliary/keyboard-shortcuts-workaround.litcoffee'
            'source/auxiliary/testrecorder.litcoffee'
            'source/auxiliary/setup.litcoffee'
        ]
        concat 'lurch-web-platform.litcoffee'
        gulp.dest 'release/'
    ]

Create a task to compile the large file created by the previous task.  We
use minification and source maps.

    gulp.task 'lwp-build', [ 'lwp-source' ],
    -> pump [
        gulp.src 'release/lurch-web-platform.litcoffee'
        sourcemaps.init()
        coffee bare : yes
        uglify()
        sourcemaps.write '.'
        gulp.dest 'release/'
    ]

Create a task to compile (with minification and source maps) a set of
auxiliary source files.

First, here are the auxiliary files:

    auxFiles = [
        'source/auxiliary/lurch-embed.litcoffee'
        'source/auxiliary/mathquill-parser.litcoffee'
        'source/auxiliary/testrecorder.litcoffee'
        'source/auxiliary/background.litcoffee'
        'source/auxiliary/worker.litcoffee'
    ]

Next, here are two tasks, one for copying source files (so that source maps
point to files that exist) and another for compiling.

    gulp.task 'aux-copy', -> pump [
        gulp.src auxFiles
        gulp.dest 'release/'
    ]
    gulp.task 'aux-build', [ 'aux-copy' ], -> pump [
        gulp.src auxFiles
        sourcemaps.init()
        coffee bare : yes
        uglify()
        sourcemaps.write '.'
        gulp.dest 'release/'
    ]

Create a task to compile (with minification and source maps) all source
files in the `experimental` folder, into that same folder.  This folder is
not in the repository, because its purpose is to let individual developers
experiment with temporary/ancillary files on their own machine before adding
new features to the repository.

    gulp.task 'exp-build', -> pump [
        gulp.src 'source/experimental/*.litcoffee'
        sourcemaps.init()
        coffee bare : yes
        uglify()
        sourcemaps.write '.'
        gulp.dest 'source/experimental/'
    ]

Create "docs" task to build the documentation using
[MkDocs](http://www.mkdocs.org).  This requires that you have `mkdocs`
installed on your system.

    gulp.task 'docs', shell.task 'mkdocs build'

Create a default task that runs all other tasks.

    gulp.task 'default', [
        'docs'
        'lwp-build'
        'aux-build'
        'exp-build'
    ]

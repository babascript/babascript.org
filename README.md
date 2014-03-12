# BabaScript.org



## Routing

/u/:id
/u/:id/group/:name
/m/

<<<<<<< HEAD
* webpage about babascript
* babascript client for web

## usage

### initialize
<script type="text/javascript" src="js/babascript.js">
var client = new Client()
=======
* client side application template
* provides **build**, **lint**, **minify**, **server** and **livereload**

## install

```
git clone geta6/grunt-city myapp
cd myapp
npm -g i grunt-cli
npm i
```

## run

```
grunt
```

## usage

```
Grunt: The JavaScript Task Runner (v0.4.2)

Usage
 grunt [options] [task [task ...]]

Options
    --help, -h  Display this help text.
        --base  Specify an alternate base path. By default, all file paths are
                relative to the Gruntfile. (grunt.file.setBase) *
    --no-color  Disable colored output.
   --gruntfile  Specify an alternate Gruntfile. By default, grunt looks in the
                current or parent directories for the nearest Gruntfile.js or
                Gruntfile.coffee file.
   --debug, -d  Enable debugging mode for tasks that support it.
       --stack  Print a stack trace when exiting with a warning or fatal error.
   --force, -f  A way to force your way past warnings. Want a suggestion? Don't
                use this option, fix your code.
       --tasks  Additional directory paths to scan for task and "extra" files.
                (grunt.loadTasks) *
         --npm  Npm-installed grunt plugins to scan for task and "extra" files.
                (grunt.loadNpmTasks) *
    --no-write  Disable writing files (dry run).
 --verbose, -v  Verbose mode. A lot more information output.
 --version, -V  Print the grunt version. Combine with --verbose for more info.
  --completion  Output shell auto-completion rules. See the grunt-cli
                documentation for more information.

Options marked with * have methods exposed via the grunt API and should instead
be specified inside the Gruntfile wherever possible.

Available tasks
          copy  Copy files. *
        coffee  Compile CoffeeScript files into JavaScript *
        stylus  Compile Stylus files into CSS *
          jade  Compile jade templates. *
    coffeelint  Validate files with CoffeeLint *
       csslint  Lint CSS files with csslint *
        uglify  Minify files with UglifyJS. *
      imagemin  Minify PNG and JPEG images *
       connect  Start a connect web server. *
         watch  Run predefined tasks whenever watched files change.
   simplemocha  Run tests with mocha *
        notify  Show an arbitrary notification whenever you need. *
  notify_hooks  Config the automatic notification hooks.
       jsbuild  Alias for "copy:js", "coffeelint", "coffee", "uglify" tasks.
      cssbuild  Alias for "copy:css", "stylus", "csslint" tasks.
      imgbuild  Alias for "copy:img", "imagemin" tasks.
         build  Alias for "imgbuild", "cssbuild", "jsbuild", "jade" tasks.
          test  Alias for "build", "simplemocha" tasks.
       default  Alias for "build", "connect", "watch" tasks.

Tasks run in the order specified. Arguments may be passed to tasks that accept
them by using colons, like "lint:files". Tasks marked with * are "multi tasks"
and will iterate over all sub-targets if no argument is specified.

The list of available tasks may change based on tasks directories or grunt
plugins specified in the Gruntfile or via command-line options.

For more information, see http://gruntjs.com/
```

## options

* port
  * static server port
  * assets server on `localhost` with port `3000` default
* mode
  * mode `dev` serves un-minified assets, default
  * mode `pro` serves minified assets
* index
  * static server fallback defaults to `index.html`

## server core

request to unexists path, fallback to index file.

```coffee
# route = req.url
# index = path.resolve 'public', 'index.html'

fs.exists route, (exist) ->
  fs.stat route, (err, stat) ->
    if exist and stat.isFile()
      return fs.createReadStream(route).pipe(res)
    return fs.createReadStream(index).pipe(res)
```

## livereload

* install [livereload extensions](http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions-)

## caution

* static server is only for preview
* is not compatible for production environment

## license
>>>>>>> 24fa75127cde8ffb9d61a70805111370dfb63bf4

### 

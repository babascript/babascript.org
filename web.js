#!/usr/bin/env node

require('coffee-script');

// Local Scope
var fs = require('fs')
  , path = require('path')
  , util = require('util')
  , hooker = require('hooker')
  , cluster = require('cluster')
  , pidfile = path.resolve('tmp', 'web.pid')
  , argv = require('optimist').boolean(['d', 'daemon', 'h', 'help']).argv;

// Exception
if (!fs.existsSync(path.resolve('tmp'))) {
  fs.mkdirSync(path.resolve('tmp'));
}

// Global Scope
global._ = require('underscore');
global._.str = require('underscore.string');
global._.date = require('moment');

// Colorize Logger
hooker.hook(console, ['log', 'info', 'warn', 'error'], {
  passName: true,
  pre: function (method) {
    switch(method) {
      case 'log':   util.print("\x1b[37m"); break;
      case 'info':  util.print("\x1b[32m"); break;
      case 'warn':  util.print("\x1b[33m"); break;
      case 'error': util.print("\x1b[31m"); break;
      default: return hooker.preempt();
    }
  },
  post: function (res, name) { util.print('\x1b[0m'); }
});

// Option Parser
argv.p = argv.port || argv.p || 3000;
argv.e = argv.env || argv.e || 'development';
argv.c = argv.concurrent || argv.c || require('os').cpus().length;
argv.d = argv.daemon || argv.d || false;
argv.h = argv.help || argv.h || false;

// Environments
process.env.NODE_ENV = argv.e || process.env.NODE_ENV || 'development';
process.env.PORT = argv.p || process.env.PORT || 3000;

// Main Application
var app = require(path.resolve('config', 'app'));

// Exit with Helper
if (argv.h || argv._[0] == 'help') {
  util.print('\n');
  console.log(app.get('appname'), 'version', app.get('version'));
  util.print('\n');
  console.log('Usage:', path.basename(process.argv[1]), '[action] [options]');
  util.print('\n');
  console.log('Actions:');
  util.print('\n');
  console.log('  start                start the server');
  console.log('  stop                 start the server');
  console.log('  status               check running or not');
  console.log('  ✗ create event [name]  create event prototype');
  console.log('  ✗ create model [name]  create model prototype');
  console.log('  help                 show this message');
  util.print('\n');
  console.log('Options:');
  util.print('\n');
  console.log('  -p, --port        listening port (3000)');
  console.log('  -e, --env         application environment (development)');
  console.log('  -c, --concurrent  process concurrents (number of cpu threads)');
  console.log('  -d, --daemon      daemonize process (false)')
  console.log('  -h, --help        show this message');
  util.print('\n');
  process.exit(1);
}

var scripts = {
  start: function () {
    // Cluster Server
    if (cluster.isMaster) {
      if (fs.existsSync(pidfile)) {
        console.error('\n'+app.get('appname'), 'already running.');
        process.exit(1);
      }
      console.log('\n'+app.get('appname'), app.get('version'), app.get('env'), '@'+app.get('port'), 'concurrent', argv.c);
      if (argv.d) console.log('daemonize process');
      util.print('\n');

      // Worker Fork
      cluster.on('fork', function(worker){
        console.log('>', 'Cluster', 'fork', worker.type, '#'+process.pid);
      });
      // Worker Listening
      cluster.on('listening', function (worker) {
        console.info('>>', worker.type, 'listening', '#'+worker.process.pid);
      });
      // Worker Down
      cluster.on('exit', function (worker) {
        console.error('<<', worker.type, 'exit', '#'+worker.process.pid);
        cluster.fork({type: worker.type}).type = worker.type;
      });
      // Fork HTTP Server
      for (var fork = 0; fork < argv.c; fork++) {
        cluster.fork({type: 'HTTP'}).type = 'HTTP';
      }
      // Daemonize
      if (argv.d) {
        require('daemon')();
      }
      // Process ID Management
      fs.writeFileSync(pidfile, process.pid);
      var unlinkPid = function () {
        fs.unlinkSync(pidfile);
      };
      process.on('exit', function () { fs.unlinkSync(pidfile); });
      process.on('SIGINT', function () { process.exit(0); });
    } else {
      if (process.env.type == 'HTTP') {
        return require('http').createServer(app).listen(app.get('port'));
      }
      console.warn('Unknown process type called', process.env.type);
    }
  },
  stop: function () {
    if (fs.existsSync(pidfile)) {
      pid = parseInt(fs.readFileSync(pidfile, 'utf-8'), 10);
      if (process.kill(pid, 'SIGINT')) {
        console.log('\n'+app.get('appname'), 'stopped.\n');
        process.exit(0);
      } else {
        console.error('\nkill', pid, 'failed: no such process.\n');
        process.exit(1);
      }
    } else {
      console.error('\n'+app.get('appname'), 'not running, pid not exists.');
      util.print('\n');
      process.exit(1);
    }
  },
  status: function () {
    if (fs.existsSync(pidfile)) {
      console.log('\n'+app.get('appname'), 'is running.\n');
    } else {
      console.log('\n'+app.get('appname'), 'not running.\n');
    }
    process.exit(0);
  }
}

// Action Parser
if (0 == argv._.length) { argv._ = ['start']; }

switch (argv._[0]) {
  case 'start': scripts.start(); break;
  case 'stop': scripts.stop(); break;
  case 'status': scripts.status(); break;
  default:
    console.error('\nUnknown action', argv._[0]);
    util.print('\n');
    process.exit(1);
}

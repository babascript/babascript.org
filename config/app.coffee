# Local Scope

require.all = require 'direquire'
path = require 'path'
express = require 'express'
mongoose = require 'mongoose'
passport = require 'passport'
connect =
  stores: (require 'connect-mongo') express
  assets: (require 'connect-asset')()
  stream: (require 'connect-stream')
  static: (require 'st')
    url: '/'
    path: path.resolve 'public'
    index: no
    passthrough: yes

# Database
mongoose.connect 'mongodb://localhost/test'

# Main Application
app = express()

app.disable 'x-powered-by'
app.set 'env', process.env.NODE_ENV
app.set 'port', process.env.PORT
app.set 'appname', (require path.resolve 'package').name
app.set 'version', (require path.resolve 'package').version
app.set 'events', require.all path.resolve 'events'
app.set 'models', require.all path.resolve 'models'
app.set 'helper', require.all path.resolve 'helper'
app.set 'views', path.resolve 'views'
app.set 'view engine', 'jade'
app.use express.favicon path.resolve 'public', 'favicon.ico'
app.use app.get('helper').logger()
app.use connect.assets
app.use connect.static
app.use express.bodyParser uploadDir: path.resolve 'tmp'
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: 'keyboardcat'
  store: new connect.stores
    mongoose_connection: mongoose.connections[0]
app.use passport.initialize()
app.use passport.session()
app.use connect.stream
app.use app.router

if (app.get 'env') is 'development'
  app.use express.errorHandler()

passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (id, done) ->
  app.get('models').User.findOne _id: id, done

# Route
(require path.resolve 'config', 'routes') app

# Exports
exports = module.exports = app

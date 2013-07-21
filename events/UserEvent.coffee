exports.UserEvent = (app) ->

  {User} = app.get('models')
  passport = require 'passport'

  passport.use new (require 'passport-local').Strategy (username, password, done) ->
    process.nextTick ->
      User.findByName username, (err, user) ->
        return (done err, no) unless user
        password = app.get('helper').shasum password
        return (done err, user) if user.pass is password
        return done err, no

  user: (req, res) ->
    res.end 'UserEvent.user'
mongoose = require 'mongoose'

exports.UserSchema = UserSchema = new mongoose.Schema
  name: { type: String, unique: yes, index: yes }
  pass: { type: String }
  icon: { type: Buffer }

UserSchema.statics.findByName = (username, done) ->
  @findOne { name: username }, {}, {}, (err, user) ->
    return done err, user

exports.User = mongoose.model 'users', UserSchema

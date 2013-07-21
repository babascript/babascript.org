mongoose = require 'mongoose'

exports.ItemSchema = ItemSchema = new mongoose.Schema
  name: { type: String }
  updated: { type: Date, default: Date.now() }
  created: { type: Date, default: Date.now() }

ItemSchema.statics.findById = (id, done) ->
  @findOne _id: id, {}, populate: 'owner', (err, item) ->
    done err, item

ItemSchema.pre 'save', (next) ->
  @updated = Date.now()
  next()

exports.Item = mongoose.model 'items', ItemSchema
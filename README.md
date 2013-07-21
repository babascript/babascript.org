# BabaScript.org
from geta6/express-city

BabaScript.org is Interactive BaBa interface on web

## install modules

`npm install`

## actions

### start

`node web start`

### stop

`node web stop`

### status check

`node web status`

## options

### -p, --port
change listening port (Default `3000`)

### -e, --env
chenge application environment (Default `development`)

### -c, --concurrent
process concurrents (Default number of cpu threads)

### -d, --daemon
daemonize process (Default `false`)

### -h, --help
show help message and exit

## Events

auto include under `./events`

```
exports.NameOfEvent = (app) ->
  {Item} = app.get 'models' # get model
  index: (req, res) -> # method
    res.render 'index'
```

## Models

auto include under `./models`

```
mongoose = require 'mongoose'
exports.NameOfModelSchema = NameOfModelSchema = new mongoose.Schema
  name: { type: String, unique: yes, index: yes }
  pass: { type: String }
  icon: { type: Buffer }
NameOfModelSchema.statics.originalMethodName = (args, done) ->
  @findOne { name: username }, {}, {}, (err, user) -> # sample
    return done err, user
exports.NameOfModel = mongoose.model 'nameofmodels', NameOfModelSchema
```

## Routes

defined on `./config/routes`

```
module.exports = (app) ->
  NameOfEvent = app.get('events').NameOfEvent app
  {ensure} = app.get 'helper'
  app.get '/', NameOfEvent.index
```
module.exports = (app) ->

  UserEvent = app.get('events').UserEvent app
  ItemEvent = app.get('events').ItemEvent app

  {ensure} = app.get 'helper'

  app.get '/', ItemEvent.index
  app.get '/user', ensure, UserEvent.user

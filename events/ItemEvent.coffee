exports.ItemEvent = (app) ->

  {Item} = app.get 'models'

  index: (req, res) ->
    res.render 'index'

class Application extends Backbone.Router

  routes:
    '': 'index'

  initialize: ->
    Backbone.history.start pushState: on

  index: ->
    $ =>
      ($ 'p').text 'routing index'

app = new Application()

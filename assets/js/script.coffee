application = new BabaScript.BaseRouter()
Backbone.history.start()
linda.io.on "connect", ->
  console.log "connect"
  
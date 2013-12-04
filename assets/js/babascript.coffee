# Application
#  routing
#  mainView
#   each View
#  tuple
# Tuple
# Tuples

# BabaScript elements
class Tuple extends Backbone.Model
  defaults:
    type: null
    key: null
    cid: null
    value: null
    format: null
    broadcast: null
    options: null

  initialize: (t)->
    @set "key", t[2]
    for key, value of t[3]
      @set key, value

  toTuple: (type)->
    return ["babascript", @get("type"), @get("cid"), @get("value")]

  getFormat: ->
    return @get(3).format

class Tuples extends Backbone.Collection
  model: Tuple

class Client

  task: null
  tasks: new Tuples()
  linda: null
  ts:    null

  constructor: ->
    io = new RocketIO().connect("http://linda.masuilab.org")
    @linda = new Linda(io)
    @ts    = new @linda.TupleSpace("baba")
    @tasks = new Tuples()
    @linda.io.on "connect", =>
      @next()

  next: (callback)->
    if @tasks.length > 0
      console.log "task is remained"
      @task = @tasks.shift()
      format = @task.getFormat() || "boolean"
      app.router.navigate "/client/takumibaba/#{format}", true
      # タスクがあるならそれを優先してやらせる
    @ts.take ["babascript", "eval"], (tuple, info)=>
      @task = new Tuple(tuple)
      @tasks.push @task
      format = @task.getFormat() || "boolean"
      app.router.navigate "/client/takumibaba/#{format}", true

  cancel: ->
    # @ts.write @task.toTuple()
    @tasks.remove @task
    @next()

  returnValue: (value, option={})->
    @task.set "value", value
    @task.set "type", "return"
    @ts.write @task.toTuple()
    @tasks.remove @task
    app.router.navigate "/client/takumibaba/index", true
    @next()

  numberOfTask: ->
    return @tasks.length()

window.app =
  client: new Client()
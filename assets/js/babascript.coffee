class Tuple extends Backbone.Model
  defaults:
    type: null
    cid: null
    format: null
    options: null

  initialize: ->


  toTuple: (type)->
    return ["babascript", @get("type"), @get("cid"), @get("value")]

class Tuples extends Backbone.Collection
  model: Tuple

class Client

  task:  null
  tasks: new Tuples()
  @linda: null
  ts:    null
  id:    null

  constructor: (name)->
    io     = new RocketIO().connect("http://linda.masuilab.org")
    @linda = new Linda(io)
    @ts    = new @linda.TupleSpace(name)
    @tasks = new Tuples()
    @id = @getOrCreateId()
    @linda.io.once "connect", =>
      @next()
      @watchUnicast()
      @watchBroadcast()
      @watchCancel()
      @ts.write ["babascript", "alive", @id]
      setInterval =>
        @ts.write ["babascript", "alive", @id]
      , 1000*60

  next: (callback)->
    if @tasks.length > 0
      console.log "task is remained"
      @task = @tasks.at 0
      format = @task.get("format") || "boolean"
      app.router.navigate "/client/#{@ts.name}/#{format}", true
      # タスクがあるならそれを優先してやらせる
    else
      @ts.take ["babascript", "eval"], (tuple, info)=>
        task = new Tuple
          type: tuple[1]
          key: tuple[2]
          format: tuple[3].format || "boolean"
          cid: tuple[3].cid || tuple[4].callback
          option: tuple[3]
        @tasks.push task
        if @tasks.length <= 1
          @task = @tasks.at 0
          format = @task.get("format") || "boolean"
          app.router.navigate "/client/#{@ts.name}/#{format}", true

  watchUnicast: ->
    @ts.take ["babascript", @id], (tuple, info)=>
      console.log "unicast!"
      console.log tuple
      task = new Tuple
        type: "unicast"
        key: tuple[2]
        format: tuple[3].format || "boolean"
        cid: tuple[3].cid || ""
        option: tuple[3]
      @tasks.push task
      if @tasks.length <= 1
        @task = @tasks.at 0
        format = @task.get("format") || "boolean"
        app.router.navigate "/client/#{@ts.name}/#{format}", true

  watchBroadcast: ->
    @ts.watch ["babascript", "broadcast"], (tuple, info)=>
      console.log "broadcast!"
      console.log tuple
      if tuple[2] is "ping"
        @ts.write ["babascript", "pong", @id]
      else
        task = new Tuple
          type: "broadcast"
          key: tuple[2]
          format: tuple[3].format || "boolean"
          cid: tuple[3].cid || ""
          option: tuple[3]
        @tasks.push task
        if @tasks.length <= 1
          @task = @tasks.at 0
          format = @task.get("format") || "boolean"
          app.router.navigate "/client/#{@ts.name}/#{format}", true

  watchCancel: ->
    @ts.watch ["babascript", "cancel"], (tuple, info)=>
      callbackId = tuple[2]
      cancelTask = @tasks.findWhere cid: callbackId
      if cancelTask?
        @tasks.remove cancelTask
        console.log @task
        console.log cancelTask
        if @task.get("cid") is cancelTask.get("cid")
          @task = null
          app.router.navigate "/client/#{@ts.name}/index", true

  cancel: ->
    @ts.write @task.toTuple()
    @tasks.remove @task
    @task = null
    @next()

  returnValue: (value, option={})->
    task = new Tuple
      type: "return"
      value: value
      cid: @task.get "cid"
    console.log task.toTuple()
    @ts.write task.toTuple()
    @tasks.remove @task
    @task = null
    app.router.navigate "/client/#{@ts.name}/index", true
    @next()

  numberOfTask: ->
    return @tasks.length()

  getOrCreateId: ->
    storage = window.localStorage
    if storage?
      if storage.getItem "id"
        return storage.getItem "id"
      else
        id = (moment().valueOf())+(Math.random()%10000).toString()
        storage.setItem "id", id
        return id
    else
      return (moment().valueOf())+(Math.random()%10000).toString()


window.Client = Client
window.app = {}
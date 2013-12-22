class Tuple extends Backbone.Model
  defaults:
    type: null
    cid: null
    format: null
    options: null

  initialize: ->


  toTuple: (type)->
    t = @get "type"
    cid = @get "cid"
    v = @get "value"
    options = @get "options"
    return ["babascript", t, cid, v, options]

  toCancelTuple: ->
    key = @get "key"
    option = @get "option"
    return ["babascript", "eval", key, option, {"callback": @get "cid"}]

class Tuples extends Backbone.Collection
  model: Tuple

class Client

  task:  null
  tasks: new Tuples()
  @linda: null
  ts:    null
  id:    null

  constructor: (name, @routingCallback)->
    io     = new RocketIO().connect("http://linda.masuilab.org")
    @linda = new Linda(io)
    @ts    = new @linda.TupleSpace(name)
    @_ts   = new @linda.TupleSpace(@getOrCreateId())
    # @unicastTs = new @linda.TupleSpace(@getOrCreateId())
    @tasks = new Tuples()
    @id = @getOrCreateId()
    @linda.io.once "connect", =>
      @next()
      @watchUnicast()
      @watchBroadcast()
      @watchCancel()
      @watchAliveCheck()

  next: (callback)->
    if @tasks.length > 0
      console.log @tasks
      @task = @tasks.at 0
      format = @task.get("format") || "boolean"
      t  = @task.get "type"
      key = @task.get "key"
      cid = @task.get "cid"
      option = {format: format, cid: cid}
      tuple = ["babascript", t, key, option, {callback: cid}]
      @routingCallback @ts, tuple
      # app.router.navigate "/client/#{@ts.name}/#{format}", true
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
          @routingCallback @ts, tuple
          # app.router.navigate "/client/#{@ts.name}/#{format}", true

  watchUnicast: ->
    # @unicastTs ["babascript", "eval"], (tuple, info)=>
    @_ts.watch ["babascript", "eval"], (tuple, info)=>
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
        @routingCallback @ts, tuple
        # app.router.navigate "/client/#{@_ts.name}/#{format}", true

  watchBroadcast: ->
    @ts.watch ["babascript", "broadcast"], (tuple, info)=>
      if tuple[2] is "ping"
        @ts.write ["babascript", "pong", @id]
        return
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
          @routingCallback @ts, tuple
          # app.router.navigate "/client/#{@ts.name}/#{format}", true

  watchCancel: ->
    @ts.watch ["babascript", "cancel"], (tuple, info)=>
      callbackId = tuple[2]
      cancelTask = @tasks.findWhere cid: callbackId
      if cancelTask?
        @tasks.remove cancelTask
        if @task.get("cid") is cancelTask.get("cid")
          @task = null
          # @routingCallback @ts, tuple
          app.router.navigate "/client/#{@ts.name}/index", true

  watchAliveCheck: ->
    @ts.watch ["babascript", "alivecheck"], (tuple, info)=>
      @ts.write ["babascript", "alive", @getOrCreateId()]

  cancel: ->
    if @tasks.length is 0
      return
    if @task.get("type" ) is "eval"
      @ts.write @task.toCancelTuple()
    @tasks.remove @task
    @task = null
    app.router.navigate "/client/#{@ts.name}/index", true
    @next()

  returnValue: (value, options={})->
    options["worker"] = @getOrCreateId()
    console.log @tasks.at(0).get("type")
    if @tasks.at(0).get("type") is "unicast"
      ts = @_ts
    else
      ts = @ts
    task = new Tuple
      type: "return"
      value: value
      cid: @task.get "cid"
      options: options
    ts.write task.toTuple()
    @tasks.remove @task
    @task = null
    app.router.navigate "/client/#{@ts.name}/index", true
    @next()

  routing: (format)->
    app.router.navigate "/client/#{@ts.name}/#{format}", true

  numberOfTask: ->
    return @tasks.length()

  getOrCreateId: ->
    return @testid ?= (moment().valueOf())+(Math.random()%10000).toString()
    # return (moment().valueOf())+(Math.random()%10000).toString()
    # storage = window.localStorage
    # if storage?
    #   if storage.getItem "id"
    #     return storage.getItem "id"
    #   else
    #     id = (moment().valueOf())+(Math.random()%10000).toString()
    #     storage.setItem "id", id
    #     return id
    # else
    #   return (moment().valueOf())+(Math.random()%10000).toString()


window.Client = Client
window.app = {}
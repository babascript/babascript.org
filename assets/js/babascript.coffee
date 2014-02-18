

#   initialize: ->


#   toTuple: (type)->
#     t = @get "type"
#     cid = @get "cid"
#     v = @get "value"
#     options = @get "options"
#     return ["babascript", t, cid, v, options]

#   toCancelTuple: ->
#     key = @get "key"
#     option = @get "option"
#     return ["babascript", "eval", key, option, {"callback": @get "cid"}]

class Tuple extends Backbone.Model
  defaults:
    baba: "script"
    type: "return"
    cid: ""
    option: {}

class Tuples extends Backbone.Collection
  model: Tuple

class Client extends io.EventEmitter

  task:  null
  tasks: null
  @linda: null
  ts:    null
  id:    null

  constructor: (name)->
    socket = io.connect "http://linda.babascript.org"
    @linda ?= new Linda().connect socket
    @ts = @linda.tuplespace name
    @tasks = new Tuples()
    @id = @getOrCreateId()
    socket.on "connect", =>
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
      @emit "get_task", @task
    else
      @ts.take {baba: "script", type: "eval"}, (err, tuple)=>
        console.log tuple
        task = new Tuple tuple.data
        if @tasks.length is 0
          @task = task
          @emit "get_task", @task
        @tasks.push task

  watchUnicast: ->
    t =
      baba: "script"
      type: "unicast"
      unicast: @getOrCreateId()
    @ts.watch t, (err, tuple)=>
      task = new Tuple tuple.data
      if @tasks.length is 0
        @task = task
        @emit "get_task", task
      @tasks.push task

  watchBroadcast: ->
    @ts.watch {baba: "script", type: "broadcast"}, (err, tuple)=>
      task = new Tuple tuple.data
      if @tasks.length is 0
        @task = task
        @emit "get_task", task
      @tasks.push task

  watchCancel: ->
    @ts.watch {baba: "script", type: "cancel"}, (err, tuple)=>
      callbackId = tuple.cid
      cancelTask = @tasks.findWhere cid: callbackId
      if cancelTask?
        @tasks.remove cancelTask
        if @task.get("cid") is cancelTask.get("cid")
          @task = null
          @emit "cancel_task"
          # @routingCallback @ts, tuple
          # app.router.navigate "/client/#{@ts.name}/index", true

  watchAliveCheck: ->
    @ts.watch {baba: "script", type: "aliveCheck"}, (err, tuple)=>
      @ts.write {baba: "script", alve: true, id: @getOrCreateId()}

  cancel: ->
    if @tasks.length is 0
      return
    if @task.get("type" ) is "eval"
      @ts.write @task.toCancelTuple()
    @tasks.remove @task
    @task = null
    @emit "cancel_task"
    # app.router.navigate "/client/#{@ts.name}/index", true
    @next()

  returnValue: (value, options={})->
    task = new Tuple
      type: "return"
      value: value
      cid: @task.get "cid"
      worker: @getOrCreateId()
      options: options
    @ts.write task
    @tasks.remove @task
    @task = null
    @emit "cancel_task"
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
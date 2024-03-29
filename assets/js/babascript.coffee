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
  connected: false

  constructor: (name)->
    socket = io.connect "http://linda.babascript.org:80/"
    # socket = io.connect "http://localhost:3000/"
    # socket = io.connect "http://172.20.10.2:3000/"
    # socket = io.connect "http://#{window.location.hostname}:3000/"
    @linda ?= new Linda().connect socket
    @ts = @linda.tuplespace name
    @reporter = @linda.tuplespace "active_task"
    @tasks = new Tuples()
    @id = @getOrCreateId()
    socket.on "connect", =>
      console.log "connect!!"
      connected = true
      @next()
      @ts.write
        type: "connect"
        name: @ts.name
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
        throw err if err
        _t =
          status: "receive"
          group: tuple.data.name
          id: @ts.name
          key: tuple.data.key
          cid: tuple.data.cid
        @reporter.write _t
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
      throw err if err
      callbackId = tuple.data.cid
      cancelTask = @tasks.findWhere cid: callbackId
      if cancelTask?
        console.log "cancel!!cancel!!"
        @tasks.remove cancelTask
        if @task.get("cid") is cancelTask.get("cid")
          @task = null
          @emit "cancel_task"
          @next()
          # @routingCallback @ts, tuple
          # app.router.navigate "/client/#{@ts.name}/index", true

  watchAliveCheck: ->
    @ts.watch {baba: "script", type: "aliveCheck"}, (err, tuple)=>
      @ts.write {baba: "script", alve: true, id: @getOrCreateId()}

  cancel: ->
    return if (@tasks.length is 0) or !@task?
    if @task.get("type") is "eval"
      @ts.write {baba: "script", type: 'cancel', cid: @task.get "cid"}
      # @ts.cancel @task.get "cid"
      # @ts.write @task.toCancelTuple()
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
      name: @ts.name
      worker: @ts.name
      # worker: @getOrCreateId()
      options: options
      _task: @task
    @ts.write task
    @tasks.remove @task
    @task = null
    @emit "cancel_task"
    # app.router.navigate "/client/#{@ts.name}/index", true
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
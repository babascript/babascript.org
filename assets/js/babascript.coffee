window.BabaScript = {}
BabaScript = window.BabaScript
# io = new RocketIO().connect("http://linda.masuilab.org")
# window.linda = new Linda(io)
# window.ts    = new linda.TupleSpace("takumibaba")

class BaseView extends Backbone.View
  el: $ "#content"

  initialize: ->

  returnValue: (value, option={})->
    BabaScript.Client.returnValue value, option

class BaseRouter extends Backbone.Router

  tasks: []
  routes:
    "doc": "doc"
    "client/:tuplespace/": "client"
    "client/:tuplespace/:view": "client"
    "": "index"

  initialize: ->
    Backbone.history.start pushState: on

  index: ->
    # console.log "index"

  doc: ->
    # console.log "doc"

  client: (tuplespace, viewName)->
    if !window.BabaScript.Client?
      @navigate "/client/#{tuplespace}/index"
      viewName = "index"
    if !BabaScript.Views[viewName]?
      return
    $("#content").empty()
    view = new BabaScript.Views[viewName]
    view.render()

class Client

  tasks: []
  currentTask: {}
  linda: null
  ts:    null

  constructor: ->
    io = new RocketIO().connect("http://linda.masuilab.org")
    @linda = new Linda(io)
    @ts    = new @linda.TupleSpace("takumibaba")
    @linda.io.on "connect", =>
      @next()

  next: ->
    @ts.take ["babascript", "eval"], (tuple, info)=>
      @tasks.push tuple
      format = tuple[3].format || "boolean"
      Application.navigate "/client/takumibaba/#{format}", true
      @currentTask = tuple

  cancel: ->
    @ts.write @currentTask

  returnValue: (value, option={})->
    @ts.write ["babascript", "return", @currentTask[4].callback, value, option]
    Application.navigate "/client/#{@ts.name}/index", true
    @next()

# Base Views
class IndexView   extends BaseView
  template: _.template ($ "#index-page").html()

  initialize: ->
    console.log "index"

  render: ->
    @$el.html @template()
    window.BabaScript.Client ?= new Client()

class BooleanView extends BaseView

  events:
    "click .js-true": "returnTrue"
    "click .js-false": "returnFalse"

  template: _.template ($ "#boolean-input-view").html()

  render: ->
    @$el.html @template({title: "hogerfuga"})

  returnTrue: ->
    console.log "true"
    @returnValue true

  returnFalse: ->
    console.log "false"
    @returnValue false

class NumberView  extends BaseView
  template: _.template ($ "#number-input-view").html()
  render: ->
    @$el.html @template()

class StringView  extends BaseView
  template: _.template ($ "#string-input-view").html()
  render: ->
    @$el.html @template()

class ListView    extends BaseView
  template: _.template ($ "#list-input-view").html()
  render: ->
    @$el.html @template()

BabaScript.Views =
  base: BaseView
  index: IndexView
  boolean: BooleanView
  number: NumberView
  string: StringView
  list: ListView
BabaScript.BaseRouter = BaseRouter
Application = new BaseRouter()
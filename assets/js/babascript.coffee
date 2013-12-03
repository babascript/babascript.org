window.BabaScript = {}
BabaScript = window.BabaScript
io = new RocketIO().connect("http://linda.masuilab.org")
window.linda = new Linda(io)
window.ts    = new linda.TupleSpace("test")

class BaseView extends Backbone.View
  el: $ "#content"

  constructor: ->
    console.log "constructor"

  returnValue: (value, option={})->
    tuple = ["babascript", "return", cid, value, option]
    ts.write tuple

class BaseRouter extends Backbone.Router

  routes:
    "doc": "doc"
    "client/": "test"
    "client/:tuplespace/:view": "test"
    "": "index"

  initialize: ->
    Backbone.history.start pushState: on

  index: ->
    console.log "index"

  doc: ->
    console.log "doc"

  test: (tuplespace, viewName)->
    console.log "routing"
    if !BabaScript.Views[viewName]?
      console.log "nai"
      return
    view = new BabaScript.Views[viewName]
    view.render()

# Base Views
class IndexView   extends BaseView
  template: _.template ($ "#index-page").html()
  render: ->
    @el.html @template()

class BooleanView extends BaseView

  events:
    "click .js-true": "returnTrue"
    "click .js-false": "returnFalse"

  template: _.template ($ "#boolean-input-view").html()
  render: ->
    @el.html @template({title: "hogerfuga"})

  returnTrue: ->
    console.log "true"

  returnFalse: ->
    console.log "false"

class NumberView  extends BaseView
  template: _.template ($ "#number-input-view").html()
  render: ->
    @el.html @template()

class StringView  extends BaseView
  template: _.template ($ "#string-input-view").html()
  render: ->
    @el.html @template()

class ListView    extends BaseView
  template: _.template ($ "#list-input-view").html()
  render: ->
    @el.html @template()

BabaScript.Views =
  base: BaseView
  index: IndexView
  boolean: BooleanView
  number: NumberView
  string: StringView
  list: ListView
BabaScript.BaseRouter = BaseRouter

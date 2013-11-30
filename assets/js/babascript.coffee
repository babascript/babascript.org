window.BabaScript = {}
BabaScript = window.BabaScript
io = new RocketIO().connect("http://localhost:5000")
window.linda = new Linda(io)
window.ts    = new linda.TupleSpace("test")

class BaseView extends Backbone.View
  el: $ "#content"

  constructor: ->
    console.log "constructor"

  returnValue: (value, option={})->
    tuple = ["babascript", "return", cid, value, option]
    ts.write tuple

class BaseRouting extends Backbone.Router

  routes:
    ":tuplespace": "test" 
    ":tuplespace/:view": "test"

  index: ->
    console.log "index"

  test: (tuplespace, viewName)->
    console.log "routing"    
    if !BabaScript.Views[viewName]? 
      console.log "nai"
      return
    view = new BabaScript.Views[viewName]
    console.log view
    view.render()

# Base Views
class IndexView   extends BaseView
  template: _.template ($ "#index-page").html()
  render: ->
    @el.html @template()

class BooleanView extends BaseView
  template: _.template ($ "#boolean-input-view").html()
  render: ->
    @el.html @template()

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
BabaScript.Applicaton = new BaseRouting()
app = window.app

class ApplicationView extends Backbone.View
  el: "#content"

  initialize: ->

  render: (el)->
    @$el.empty()
    @$el.html el

  change: (viewName)->
    view = switch viewName
      when "", "index"
        new IndexView()
      when "boolean", "bool"
        new BooleanView()
      when "string"
        new StringView()
      when "list"
        new ListView()
      when "number", "int"
        new NumberView()
      else
        new IndexView()
    @render view.el

class BaseView extends Backbone.View
  tagName: "div"

  initalize: ->
    _.bindAll @, "render"
    app.client.task.bind "change:[cid]"

  returnValue: (value, option={})->
    app.client.returnValue value, option

class Router extends Backbone.Router

  routes:
    "": "index"
    "doc": "doc"
    "client/:tuplespace/": "client"
    "client/:tuplespace/:view": "client"

  initialize: ->
    Backbone.history.start pushState: on

  index: ->
    console.log "index"

  doc: ->
    console.log "doc"

  client: (tuplespace, viewName)->
    if window.app.client.tasks.length is 0
      viewName = "index"
      @navigate "/client/takumibaba/index"
    app.mainView.change viewName

class IndexView extends BaseView
  template: _.template ($ "#index-page").html()

  initialize: ->
    @$el.html @template()

class StringView extends BaseView
  template: _.template ($ "#string-input-view").html()
  events:
    "click button": "returnString"

  initialize: ->
    option =
      title: app.client.task.get "key"
    @render option

  render: (option)->
    @$el.html @template option

  returnString: ->
    console.log @$el.find(".string-value")
    @returnValue @$el.find(".string-value").val()

class BooleanView extends BaseView
  template: _.template ($ "#boolean-input-view").html()
  events:
    "click .true":  "returnTrue"
    "click .false": "returnFalse"

  initialize: ->
    option =
      title: app.client.task.get "key"
    @render(option)

  render: (option)->
    @$el.html @template(option)

  returnTrue: ->
    @returnValue true
  returnFalse: ->
    @returnValue false

class ListView extends BaseView
  template: _.template ($ "#list-input-view").html()
  events:
    "click button": "returnItem"

  initialize: ->
    option =
      title: app.client.task.get "key"
      items: app.client.task.get "list"
    @render option

  render: (option)->
    console.log option
    @$el.html @template option

  returnItem: ->
    @returnValue @$el.find("select").val()

class NumberView extends BaseView
  template: _.template ($ "#number-input-view").html()
  events:
    "click button": "returnNumber"

  initialize: ->
    option =
      title: app.client.task.get "key"
    @render option

  render: (option)->
    @$el.html @template option

  returnNumber: ->
    @returnValue parseInt(@$el.find(".number-value").val())

app.mainView = new ApplicationView()
app.router   = new Router()
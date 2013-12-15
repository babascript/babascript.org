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
        new ClientView()
      when "boolean", "bool"
        new BooleanView()
      when "string"
        new StringView()
      when "list"
        new ListView()
      when "number", "int"
        new NumberView()
      else
        new ClientView()
    @render view.el

class BaseView extends Backbone.View
  tagName: "div"

  initalize: ->
    @$el.addClass "row"

  returnValue: (value, option={})->
    app.Client.returnValue value, option

  cancel: ->
    app.Client.cancel()

  render: ->

class HeaderView extends Backbone.View
  el: "#header"

  changeTitle: (title)->
    $(".header-title").html title

class Router extends Backbone.Router

  routes:
    "": "index"
    "doc": "doc"
    "client/:tuplespace/": "client"
    "client/:tuplespace/:view": "client"

  initialize: ->
    Backbone.history.start pushState: on

  index: ->
    $(".header-title").html "babascript.org"
    indexView = new IndexView()
    app.mainView.render indexView.el
    console.log "index"

  doc: ->
    console.log "doc"

  client: (tuplespace, viewName)->
    window.app.Client ?= new Client tuplespace
    if !window.app.Client.task?
      viewName = "index"
      @navigate "/client/#{tuplespace}/index"
    $(".header-title").html "BabaScript Client -#{viewName}-"
    app.mainView.change viewName

class IndexView extends BaseView
  template: _.template ($ "#index-page").html()

  initialize: ->
    @$el.html @template()

class ClientView extends BaseView
  template: _.template ($ "#client-page").html()

  initialize: ->
    @$el.html @template()

class StringView extends BaseView
  template: _.template ($ "#string-input-view").html()
  events:
    "click button": "returnString"

  initialize: ->
    option =
      title: app.Client.task.get "key"
    @render option

  render: (option)->
    @$el.html @template option

  returnString: ->
    @returnValue @$el.find(".string-value").val()

class BooleanView extends BaseView
  template: _.template ($ "#boolean-input-view").html()
  events:
    "click .true":  "returnTrue"
    "click .false": "returnFalse"

  initialize: ->
    option =
      title: app.Client.task.get "key"
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
      title: app.Client.task.get "key"
      items: app.Client.task.get("option").list
    @render option

  render: (option)->
    @$el.html @template option

  returnItem: ->
    @returnValue @$el.find("select").val()

class NumberView extends BaseView
  template: _.template ($ "#number-input-view").html()
  events:
    "click button": "returnNumber"

  initialize: ->
    option =
      title: app.Client.task.get "key"
    @render option

  render: (option)->
    @$el.html @template option

  returnNumber: ->
    @returnValue parseInt(@$el.find(".number-value").val())

app.mainView = new ApplicationView()
app.router   = new Router()
app.header   = new HeaderView()
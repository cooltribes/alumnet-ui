@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application
  App.promises = 0

  App.on "start", (options) ->
    App.api_endpoint = options.api_endpoint
    App.temp_token = options.temp_token
    $.ajaxSetup
      headers:
        'Authorization': 'Token token="' + App.temp_token + '"'
        'Accept': 'application/vnd.alumnet+json;version=1'

  if Backbone.history
    Backbone.history.start()

  App.addRegions
    headerRegion: "#header-region"
    mainRegion: "#main-region"
    tableRegion: "#groups-table"

  App.navigate = (route, options)->
    options || (options = {})
    Backbone.history.navigate(route, options)

  App.getCurrentRoute = ->
    Backbone.history.fragment

  # if this.getCurrentRoute() == ""
  #   App.trigger("groups:home")

  App.reqres.setHandler 'progress', (promise) ->
    App.promises++
    NProgress.start()
    return promise
      .progress ->
        NProgress.inc()
      .always ->
        App.promises--
        NProgress.done() unless App.promises

  Backbone.ajax = ->
    App.request 'progress', Backbone.$.ajax.apply(Backbone.$, arguments)

  App
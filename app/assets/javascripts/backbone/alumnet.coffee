@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application
  App.promises = 0

  App.addRegions
    mainRegion: "#main-region"
    tableRegion: "#groups-table"

  App.navigate = (route, options)->
    options || (options = {})
    Backbone.history.navigate(route, options)

  App.getCurrentRoute = ->
    Backbone.history.fragment

  App.on "start", ->
    $.ajaxSetup
      headers:
        'Authorization': 'Token token="o7J9yQrgMVcCykfmqceA7jE-kGvYQz6-ecYtzND3"'
        'Accept': 'application/vnd.alumnet+json;version=1'
    if Backbone.history
      Backbone.history.start()

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
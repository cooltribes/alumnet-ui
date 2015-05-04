@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application
  App.promises = 0

  App.on 'before:start', (options) ->
    App.api_endpoint = options.api_endpoint
    current_user_token = App.request 'user:token'
    App.current_token = current_user_token
    if current_user_token
      $.ajaxSetup
        headers:
          'Authorization': 'Token token="' + current_user_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'
      # here get all info of use from api and set in a backbone model
      @current_user = App.request 'get:current_user'#, refresh: true
      @startPusher(options.pusher_key, @current_user)
      App.request 'get:countries'
      App.request 'get:aiesec_countries'

  App.on 'start', ->
    if Backbone.history
      Backbone.history.start()      
      App.navigate('#posts', {trigger: true}) if App.getCurrentRoute() == ""


  App.addRegions
    headerRegion: "#header-region"
    submenuRegion: "#submenu-region"
    mainRegion: 
      selector: "#main-region"
      # regionClass: AnimatedRegion
    tableRegion: "#groups-table"

  App.navigate = (route, options)->
    options || (options = {})
    Backbone.history.navigate(route, options)

  App.getCurrentRoute = ->
    Backbone.history.fragment


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
@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application
  App.promises = 0

  App.rootRoute = '#groups/new' #main page to take the user

  App.on "start", (options) ->
    App.api_endpoint = options.api_endpoint
    current_user_token = App.request 'user:token'
    if current_user_token
      $.ajaxSetup
        headers:
          'Authorization': 'Token token="' + current_user_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'
      # here get all info of use from api and set in a backbone model
      @current_user = App.request 'get:current_user'#, refresh: true

    #else
      #redirect to login


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

  # App.on 'initialize:after', () ->
  #   if Backbone.history
  #     Backbone.history.start()    
  #     AlumNet.navigate(AlumNet.rootRoute, trigger: true)

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
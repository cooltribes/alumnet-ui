@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    headerRegion: "#header-region"
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
        'Authorization': 'Token token="N9DLEjZbGevq6MS2qo4mTw2XH5nCnQULxcxgFec3"'
        'Accept': 'application/vnd.alumnet+json;version=1'
    if Backbone.history
      Backbone.history.start()

    ###if this.getCurrentRoute() == ""
      App.trigger("home")###

  App
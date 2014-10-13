@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application

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
        'Authorization': 'Token token="YxLhAmqp4yg6WKrYK5kBbJKozw1khf7sxDtPREx-"'
        'Accept': 'application/vnd.alumnet+json;version=1'
    if Backbone.history
      Backbone.history.start()

    # if this.getCurrentRoute() == ""
    #   App.trigger("groups:home")
  App
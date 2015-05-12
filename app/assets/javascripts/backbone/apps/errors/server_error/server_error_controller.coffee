@AlumNet.module 'ErrorsApp.ServerError', (ServerError, @AlumNet, Backbone, Marionette, $, _) ->
  class ServerError.Controller
    show: ->
      page = new ServerError.View
      AlumNet.mainRegion.show(page)


@AlumNet.module 'ErrorsApp.NotFound', (NotFound, @AlumNet, Backbone, Marionette, $, _) ->
  class NotFound.Controller
    show: ->
      page = new NotFound.View
      AlumNet.mainRegion.show(page)


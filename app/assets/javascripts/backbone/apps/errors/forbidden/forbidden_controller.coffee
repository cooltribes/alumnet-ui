@AlumNet.module 'ErrorsApp.Forbidden', (Forbidden, @AlumNet, Backbone, Marionette, $, _) ->
  class Forbidden.Controller
    show: ->
      page = new Forbidden.View
      AlumNet.mainRegion.show(page)


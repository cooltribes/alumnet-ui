@AlumNet.module 'ErrorsApp.Banned', (Banned, @AlumNet, Backbone, Marionette, $, _) ->
  class Banned.Controller
    show: ->
      page = new Banned.View
      AlumNet.mainRegion.show(page)


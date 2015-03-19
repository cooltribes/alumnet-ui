@AlumNet.module 'HomeApp.Prueba', (Prueba, @AlumNet, Backbone, Marionette, $, _) ->
  class Prueba.Controller
    prueba: ->
      pruebaView = new Prueba.View
      AlumNet.mainRegion.show(pruebaView)



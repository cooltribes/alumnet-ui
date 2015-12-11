@AlumNet.module 'PagesApp.Donate', (Donate, @AlumNet, Backbone, Marionette, $, _) ->
  class Donate.Controller
    showDonate: ->
      page = new Donate.View
      AlumNet.mainRegion.show(page)
      #AlumNet.execute('render:pages:submenu')
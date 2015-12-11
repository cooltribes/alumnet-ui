@AlumNet.module 'PagesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: ->
      page = new About.View
      AlumNet.mainRegion.show(page)
      #AlumNet.execute('render:pages:submenu')
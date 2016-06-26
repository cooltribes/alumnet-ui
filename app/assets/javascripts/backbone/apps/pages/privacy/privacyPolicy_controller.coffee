@AlumNet.module 'PagesApp.Privacy', (Privacy, @AlumNet, Backbone, Marionette, $, _) ->
  class Privacy.Controller
    showPrivacy: ->
      page = new Privacy.View
      AlumNet.mainRegion.show(page)
      AlumNet.execute 'show:footer'
      #AlumNet.execute('render:pages:submenu')




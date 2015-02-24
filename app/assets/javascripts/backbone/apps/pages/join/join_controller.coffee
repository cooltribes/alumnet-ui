@AlumNet.module 'PagesApp.Join', (Join, @AlumNet, Backbone, Marionette, $, _) ->
  class Join.Controller
    showJoin: ->
      page = new Join.View
      AlumNet.mainRegion.show(page)





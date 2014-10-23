@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    renderInLayout: (layout)->
      aboutView = new About.View
        model: layout.model
      layout.content.show(aboutView)
      aboutView.on 'about:edit', (text)->
        alert text

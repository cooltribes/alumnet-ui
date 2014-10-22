@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'groups/about/templates/about'
    events:
      'click h2': 'test'
    test: (e)->
      text = $(e.currentTarget).text()
      this.trigger('about:edit', text)

@AlumNet.module 'GroupsApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->

  class Home.AboutView extends Marionette.ItemView
    template: 'groups/home/templates/about'

  class Home.Layout extends Marionette.LayoutView
    template: 'groups/home/templates/main'
    regions: {
      content: '#timeline-main-content'
    }

    events: {
      'click #js-about': 'showAbout'
    }

    showAbout: (e)->
      e.preventDefault()
      this.trigger 'show:about'
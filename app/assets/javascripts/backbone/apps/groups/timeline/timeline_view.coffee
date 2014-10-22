@AlumNet.module 'GroupsApp.Timeline', (Timeline, @AlumNet, Backbone, Marionette, $, _) ->

  class Timeline.About extends Marionette.ItemView
    template: 'groups/timeline/templates/about'

  class Timeline.Layout extends Marionette.LayoutView
    template: 'groups/timeline/templates/main'
    regions: {
      content: '#timeline-main-content'
    }

    events: {
      'click #js-about': 'timelineAbout'
    }

    timelineAbout: (e)->
      e.preventDefault()
      this.trigger 'timeline:about', this
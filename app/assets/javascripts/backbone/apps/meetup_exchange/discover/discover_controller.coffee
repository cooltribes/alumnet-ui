@AlumNet.module 'MeetupExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch()
      discoverView = new Discover.List
        collection: tasks

      AlumNet.mainRegion.show(discoverView)
      AlumNet.execute('render:meetup_exchange:submenu', undefined, 3)

@AlumNet.module 'MeetupExchangeApp.YourTasks', (YourTasks, @AlumNet, Backbone, Marionette, $, _) ->
  class YourTasks.Controller
    your_tasks: ->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/my'
      myTasksView = new YourTasks.List
        collection: tasks

      AlumNet.mainRegion.show(myTasksView)
      #AlumNet.execute('render:meetup_exchange:submenu', undefined, 1)

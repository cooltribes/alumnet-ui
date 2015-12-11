@AlumNet.module 'BusinessExchangeApp.YourTasks', (YourTasks, @AlumNet, Backbone, Marionette, $, _) ->
  class YourTasks.Controller
    your_tasks: ->
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/my'
      myTasksView = new YourTasks.List
        collection: tasks

      AlumNet.mainRegion.show(myTasksView)
      #AlumNet.execute('render:business_exchange:submenu', undefined, 1)

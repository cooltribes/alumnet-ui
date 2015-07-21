@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch()
      tasksList = new Discover.TasksList
        collection: tasks

      discoverLayout = new Discover.Layout

      AlumNet.mainRegion.show(discoverLayout)
      discoverLayout.content.show(tasksList)
      AlumNet.execute('render:business_exchange:submenu', undefined, 3)

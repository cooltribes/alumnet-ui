@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: (view = "people")->

      if view == "tasks"
        tasks = new AlumNet.Entities.BusinessExchangeCollection
        tasks.fetch()
        discoverView = new Discover.TasksList
          collection: tasks
      
      else if view == "people"
        profiles = new AlumNet.Entities.BusinessCollection
        profiles.url = AlumNet.api_endpoint + "/business"
        profiles.fetch()
        discoverView = new Discover.ProfilesList
          collection: profiles    

      console.log view    
      console.log discoverView    
      
      discoverLayout = new Discover.Layout
        view: view

      AlumNet.mainRegion.show(discoverLayout)
      discoverLayout.content.show(discoverView)
      AlumNet.execute('render:business_exchange:submenu', undefined, 3)

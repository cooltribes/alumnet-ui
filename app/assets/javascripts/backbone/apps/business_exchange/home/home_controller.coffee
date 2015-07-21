@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Controller extends AlumNet.Controllers.Base
    initialize: ->
      AlumNet.execute('render:business_exchange:submenu', undefined, 5)

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>        
        @showTasks()

      @show @layout
      
      # AlumNet.mainRegion.show(discoverView)

    getLayoutView: ->
      view = new Home.Layout
        model: AlumNet.current_user
     
    showTasks: ->
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        data: 
          limit: 3      

      view = new Home.Tasks
        collection: tasks

      @layout.tasks.show view  

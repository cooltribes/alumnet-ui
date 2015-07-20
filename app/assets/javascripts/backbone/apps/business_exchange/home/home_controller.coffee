@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Controller extends AlumNet.Controllers.Base
    initialize: ->
      AlumNet.execute('render:business_exchange:submenu', undefined, 5)

      @layout = @getLayoutView()


      @show @layout
      
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        data: 
          limit: 3      

      # AlumNet.mainRegion.show(discoverView)

    getLayoutView: ->
      view = new Home.Layout
     

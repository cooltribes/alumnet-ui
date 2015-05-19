@AlumNet.module 'AdminApp.UserStats', (UserStats, @AlumNet, Backbone, Marionette, $, _) ->
  
  class UserStats.Controller extends AlumNet.Controllers.Base    
    
    showStats: (options)->
      AlumNet.execute('render:admin:users:submenu', undefined, 2)

      @layout = @getLayoutView()
      AlumNet.mainRegion.show @layout

      @allUsersTab()



    showTab: (tab_name) ->
      switch tab_name
        when 'all_users' then @allUsersTab()
        when 'users' then @allUsersTab()
        when 'members' then @allUsersTab()  
        when 'lt_members' then @allUsersTab()  

    allUsersTab: ->      
      # new UserStats.Controller
      #   region: @layout.tab_content_region   

      # data = new google.visualization.DataTable()
      # data.addColumn('string', 'Topping');
      # data.addColumn('number', 'Slices');
      # data.addRows([
      #   ['Mushrooms', 3],
      #   ['Onions', 1],
      #   ['Olives', 1],
      #   ['Zucchini', 1],
      #   ['Pepperoni', 2]
      # ]);

      graphsCollection = new AlumNet.Entities.UserStatsCollection
      graphsListView = new UserStats.Graphics
        collection: graphsCollection

      
      #Model for general graph
      generalStats = new AlumNet.Entities.UserStats
      graphsCollection.add(generalStats)
        
      current_user = AlumNet.current_user
      canChangeRegion = canChangeCountry = true  
      country_id = current_user.profile.get("residence_country").id        
      region_id = current_user.profile.get("residence_country").region.id

      region_name = country_name = ""
      reg = current_user.get("is_regional_admin")
      nat = current_user.get("is_nacional_admin")

      if reg || nat

        region_id = current_user.get("admin_region_id")        
        region_name = current_user.get("admin_region_name")        
        country_id = current_user.get("admin_country_id")        
        country_name = current_user.get("admin_country_name")        
        
        if reg
          canChangeRegion = false
          canChangeCountry = true                 
        else 
          canChangeRegion = false
          canChangeCountry = false
       

      #Model for region graph      
      regionStats = new AlumNet.Entities.UserStats
        graphType: 1
        location_id: region_id
        location_name: region_name
        canChange: canChangeRegion
      graphsCollection.add(regionStats)


      #Model for counrty graph
      countryStats = new AlumNet.Entities.UserStats
        graphType: 2
        location_id: country_id
        location_name: country_name        
        canChange: canChangeCountry
      graphsCollection.add(countryStats)

      
      #Show graph list in the general layout
      @layout.tab_content_region.show(graphsListView)
      
      # layout = @layout

      generalStats.fetch
        data: 
          q: generalStats.get("q")

      regionStats.fetch
        data:
          q: regionStats.get("q")

      countryStats.fetch
        data:
          q: countryStats.get("q")


        # data: @get("q")
        
      # countryStats.fetch
      #   data: @get("q")

        # success: (model)->
        #   model.trigger("")
          # users = model.get("users")
          # members = model.get("members")
          # lt_members = model.get("lt_members")

          # graph = new AlumNet.Utilities.GoogleChart
          #   chartType: 'ColumnChart',
          #   dataTable: [
          #     ['Country','Users', 'Members', 'LT Members'],
          #     ['Users', users, members, lt_members]
          #   ]
          #   options:
          #     'title': 'Registrants'

          # layout.tab_content_region.show(graph)




    getLayoutView: ->
      view = new UserStats.Layout

      @listenTo view, 'tab_selected', (tab_name) ->
        @showTab tab_name

      view  
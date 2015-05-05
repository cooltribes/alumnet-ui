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
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'ColumnChart',
        dataTable: [
          ['Pais','Users', 'Members', 'LT Members'],
          ['Users', 700, 300, 400]
        ]
        options:
          'title': 'Registrants'

      @layout.tab_content_region.show(graph)
    getLayoutView: ->
      view = new UserStats.Layout

      @listenTo view, 'tab_selected', (tab_name) ->
        @showTab tab_name

      view  
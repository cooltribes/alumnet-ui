@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Controller extends AlumNet.Controllers.Base    

    initialize: (options) ->
      @layout = @getLayoutView()
      
      AlumNet.execute('render:admin:dashboard:submenu', undefined, 0)
      @dataTableChartType1 = [
          ['Year', 'Sales', 'Expenses'],
          ['2013',  1000,      400],
          ['2014',  1170,      460],
          ['2015',  660,       1120],
          ['2016',  1030,      540]
        ]

      @listenTo @layout, 'show', =>        
        @showGraphType1 @dataTableChartType1

      @show @layout


    getLayoutView: ->
      view = new Users.Layout
      view  
      

    showGraphType1: ->
      view = new Users.ChartType1
      @layout.chart_type_1.show view
      view.drawGraph()

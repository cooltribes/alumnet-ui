@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Controller extends AlumNet.Controllers.Base    

    initialize: (options) ->
      
      AlumNet.execute('render:admin:dashboard:submenu', undefined, 0)

      @initialDates = 
        start: "2015-01-01"
        end: moment().format("YYYY-MM-DD")

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>        
        @showGraphType1()
        @showGraphType2()

      @show @layout


    getLayoutView: ->
      view = new Users.Layout
        dates: @initialDates

      @listenTo view, "submit", @fetchDataForCharts        
      view  


    fetchDataForCharts: (dates)->
      @fetchDataType1 dates
      

    fetchDataType1: (dates)->
      data = [
          ['Year', 'Lt Members', 'Members', "Registrants"],
          ['2013',  1000,      400, 550],
          ['2014',  1170,      460, 766],
          ['2015',  660,       1120, 829],
          ['2016',  1030,      540, 900]
        ]

      @viewChartType1.drawGraph data
    
    fetchDataType2: (dates)->
      data = [
          ['Types', 'Count'],
          ['Lt Members',     11],
          ['Members',      7],
          ['Registrants',  9],          
        ]

      @viewChartType2.drawGraph data
      

    showGraphType1: ->
      view = new Users.ChartType1
      @layout.chart_type_1.show view
      @viewChartType1 = view

      @fetchDataType1 @initialDates
    

    showGraphType2: ->
      view = new Users.ChartType2
      @layout.chart_type_2.show view
      @viewChartType2 = view

      @fetchDataType2 @initialDates

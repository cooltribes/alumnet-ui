@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Controller extends AlumNet.Controllers.Base    

    initialize: (options) ->
      
      AlumNet.execute('render:admin:dashboard:submenu', undefined, 0)

      @initialDates = 
        start: "2014-01-01"
        end: moment().format("YYYY-MM-DD")

      initialInterval = "years"  

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
      @fetchDataType2 dates
      

    fetchDataType1: (dates)->
     
      interval = @viewChartType1.interval

      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/type_of_membership"
        data:
          init_date: dates.start
          end_date: dates.end
          interval: interval
        dataType: 'json'
        success: (data)=>    
          @viewChartType1.drawGraph data.line

    
    fetchDataType2: (dates)->
      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/type_of_membership"
        data:
          init_date: dates.start
          end_date: dates.end
          interval: "years" #doesn't matter the interval
        dataType: 'json'
        success: (data)=>  
          @viewChartType2.drawGraph data.pie
      

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

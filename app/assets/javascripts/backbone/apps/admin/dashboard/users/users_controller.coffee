@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Controller extends AlumNet.Controllers.Base    

    initialize: (options) ->
      
      AlumNet.execute('render:admin:dashboard:submenu', undefined, 0)

      #for type of alumni charts ------------
      @initialDates = 
        start: "2014-01-01"
        end: moment().format("YYYY-MM-DD")

      @initialInterval = "days"

      #For map charts --------------
      @initialGeo = "countries"
      @initialType = "4" # 1:regist, 2:memb, 3:ltmemb, 4:total

      #initialize layout and show all charts ------------
      @layout = @getLayoutView()

      @curDates = @layout.dates

      @listenTo @layout, 'show', =>        
        @showGraphType1()
        @showGraphType2()
        @showGraphMap1()

      @show @layout


    getLayoutView: ->
      view = new Users.Layout
        dates: @initialDates

      @listenTo view, "submit", @fetchDataForCharts        

      view  


    fetchDataForCharts: ()->
      @fetchDataType1 @curDates
      @fetchDataType2 @curDates
      

    fetchDataType1: (dates)->     
      interval = @viewChartType1.getInterval()

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
          interval: "years" #the interval is irrelevant for this chart, can by any of valid ones.
        dataType: 'json'
        success: (data)=>  
          @viewChartType2.drawGraph data.pie
      

    fetchDataMap1: ()->
      geo = @viewChartMap1.getGeo()

      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/country_and_region"
        data:
          init_date: @curDates.start
          end_date: @curDates.end
          geo: geo
        dataType: 'json'
        success: (data)=>  
          @viewChartMap1.drawGraph data

    # METHODS FOR SHOWING EACH CHART
    showGraphType1: ->
      view = new Users.ChartType1
        interval: @initialInterval

      @layout.chart_type_1.show view
      @viewChartType1 = view

      view.on "changeInterval", (object)=>
        @fetchDataType1 @curDates

      @fetchDataType1 @curDates
    

    showGraphType2: ->
      view = new Users.ChartType2
      @layout.chart_type_2.show view
      @viewChartType2 = view

      @fetchDataType2 @curDates


    showGraphMap1: ->
      view = new Users.ChartMap1
        geo: @initialGeo
        type: @initialType
        
      @layout.chart_map_1.show view
      @viewChartMap1 = view

      @fetchDataMap1()

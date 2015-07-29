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
        @showGraphMap()
        @showGraphGeneration()
        @showGraphSeniority()

      @show @layout


    getLayoutView: ->
      view = new Users.Layout
        dates: @initialDates

      @listenTo view, "submit", @fetchDataForCharts        

      view  


    fetchDataForCharts: ()->
      @fetchDataType1()
      @fetchDataType2()
      @fetchDataMap()      
      @fetchDataGeneration()      
      @fetchDataSeniority()      
      

    fetchDataType1: ()->     
      interval = @viewChartType1.getInterval()

      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/type_of_membership"
        data:
          init_date: @curDates.start
          end_date: @curDates.end
          interval: interval
        dataType: 'json'
        success: (data)=>    
          @viewChartType1.drawGraph data.line

    
    fetchDataType2: ()->
      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/type_of_membership"
        data:
          init_date: @curDates.start
          end_date: @curDates.end
          interval: "years" #the interval is irrelevant for this chart, can by any of valid ones.
        dataType: 'json'
        success: (data)=>  
          @viewChartType2.drawGraph data.pie
      

    fetchDataMap: ()->
      geo = @viewChartMap.getGeo()      
      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/country_and_region"
        data:
          init_date: @curDates.start
          end_date: @curDates.end
          geo: geo
        dataType: 'json'
        success: (data)=>  
          @viewChartMap.drawAll data

    
    fetchDataGeneration: ()->
      Backbone.ajax      
        url: AlumNet.api_endpoint + "/admin/stats/generation_and_gender"
        data:
          init_date: @curDates.start
          end_date: @curDates.end
        dataType: 'json'
        success: (data)=>  
          @viewChartGeneration.drawGraph data      

    fetchDataSeniority: ()->
      # Backbone.ajax      
      #   url: AlumNet.api_endpoint + "/admin/stats/generation_and_gender"
      #   data:
      #     init_date: @curDates.start
      #     end_date: @curDates.end
      #   dataType: 'json'
      #   success: (data)=>  
      #     @viewChartGeneration.drawGraph data          
      data = [
        ['Task', 'Hours per Day']
        ['Top Management',     11]
        ['Middle Management',      2]
        ['Experienced',  2]
        ['Others', 2]
        ['Entry Level',    7]
      ]
      @viewChartSeniority.drawGraph data          


    # METHODS FOR SHOWING EACH CHART-----------------------------    
    showGraphType1: ->
      view = new Users.ChartType1
        interval: @initialInterval

      @layout.chart_type_1.show view
      @viewChartType1 = view

      view.on "changeInterval", ()=>
        @fetchDataType1 @curDates

      @fetchDataType1 @curDates
    

    showGraphType2: ->
      view = new Users.ChartType2
      @layout.chart_type_2.show view
      @viewChartType2 = view

      @fetchDataType2 @curDates


    showGraphMap: ->
      view = new Users.ChartMap
        geo: @initialGeo
        type: @initialType

      @layout.chart_map_1.show view
      @viewChartMap = view

      view.on "changeGeo", ()=>
        @fetchDataMap()


      @fetchDataMap()

    
    showGraphGeneration: ->
      view = new Users.ChartGeneration
      @layout.chart_generation.show view
      @viewChartGeneration = view

      @fetchDataGeneration()

    
    showGraphSeniority: ->
      view = new Users.ChartSeniority
      @layout.chart_seniority.show view
      @viewChartSeniority = view

      @fetchDataSeniority()

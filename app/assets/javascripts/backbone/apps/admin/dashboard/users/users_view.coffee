@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Layout extends Marionette.LayoutView
    template: 'admin/dashboard/users/templates/layout'

    ui:
      start_date: ".js-start-date"
      end_date: ".js-end-date"
      submit: ".js-submit"

    events:
      'click @ui.submit' : 'sendDates'

    regions:
      chart_type_1: '.chart_type_1'
      chart_type_2: '.chart_type_2'
      chart_map_1: '.chart_map_1'


    initialize: (options)->
      @dates = options.dates


    templateHelpers: ()->
      start_date: @dates.start  
      end_date: @dates.end  


    onRender: () ->
      @ui.start_date.Zebra_DatePicker
        show_icon: false
        view: 'years'
        default_position: 'below'
        show_clear_date: false
        show_select_today: false
        direction: [@dates.start, @dates.end]
        pair: @ui.end_date

      @ui.end_date.Zebra_DatePicker
        show_icon: false
        view: 'years'
        default_position: 'below'
        show_clear_date: false
        direction: [true, @dates.end]
        

    sendDates: (e)->
      e.preventDefault()
      a = @ui.start_date.val()
      b = @ui.end_date.val()
      return unless a != "" && b != ""

      @dates.start = a
      @dates.end = b

      @trigger "submit"
        
        
  
  class Users.ChartType1 extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"
    
    modelEvents:
      "change:interval": "changeInterval"

    bindings:
      "[name=interval]": "interval"

    initialize:(options)->
      @model = new Backbone.Model
        interval: options.interval


    changeInterval: ->
      @trigger "changeInterval"


    getInterval: ->
      @model.get "interval"

    onRender: ->
      @stickit()    

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'AreaChart',
        dataTable: dataTable
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          # 'titleTextStyle': { 'fontSize': 16 }

      @ui.graph_section.showAnimated(graph.render().el)


  class Users.ChartType2 extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'PieChart',
        dataTable: dataTable
        options:
          is3D: true
          'legend': {'position': 'bottom', 'alignment':'center'}    
          'height': 270                

      @ui.graph_section.showAnimated(graph.render().el)


  class Users.ChartMap1 extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graphMap'

    ui:
      graph_section: ".js-graph"
    
    modelEvents:
      "change:geo": "changeGeo"

    bindings:
      "[name=geo]": "geo"

    initialize:(options)->      
      @model = new Backbone.Model
        geo: options.geo        
        type: options.type #type 1:regist, 2:memb, 3:ltmemb, 4:total      

    changeGeo: ->
      @trigger "changeGeo"

    getGeo: ->
      @model.get "geo"

    onRender: ->
      @stickit()    

    drawGraph: (dataTable)->

      console.log dataTable
      newTable = []
      _.each dataTable, (country, index, table)->
        newTable[index] = [country[0], country[@model.get("type")]]
      ,
        @ #Context

      console.log "newtable"    
      console.log newTable    

      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'GeoChart',
        dataTable: newTable
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270

      @ui.graph_section.showAnimated(graph.render().el)
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

    initialize: (options)->
      @dates = options.dates

    templateHelpers: ()->
      start_date: @dates.start  
      end_date: @dates.end  

    onRender: () ->
      @ui.start_date.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: [@dates.start, @dates.end]
        pair: @ui.end_date

      @ui.end_date.Zebra_DatePicker
        show_icon: false
        # show_select_today: true
        view: 'years'
        default_position: 'below'
        direction: [true, @dates.end]
        

    sendDates: (e)->
      e.preventDefault()
      a = @ui.start_date.val()
      b = @ui.end_date.val()
      return unless a != "" && b != ""

      dates = 
        start: a
        end: b

      @trigger "submit", dates
        
        
  
  class Users.ChartType1 extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'AreaChart',
        dataTable: dataTable
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          # 'height': 270
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

      @ui.graph_section.showAnimated(graph.render().el)
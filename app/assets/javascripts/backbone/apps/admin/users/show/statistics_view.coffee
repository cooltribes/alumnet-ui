@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.StatisticsGraph extends Marionette.ItemView
    template: 'admin/users/show/templates/_statistics_graph'
    className: 'container'

    ui:
      bar_graph_container: '.js-bar-graph'
      column_graph_container: '.js-column-graph'

    initialize: (options)->
      @statistics = options.statistics

    onRender: ->
      bar_graph = new AlumNet.Utilities.GoogleChart
        chartType: 'BarChart',
        dataTable: @statistics.bar_data
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true
      column_graph = new AlumNet.Utilities.GoogleChart
        chartType: 'ColumnChart',
        dataTable: @statistics.column_data
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true


      @ui.bar_graph_container.showAnimated(bar_graph.render().el)
      @ui.column_graph_container.showAnimated(column_graph.render().el)

  class UserShow.StatisticsData extends Marionette.ItemView
    template: 'admin/users/show/templates/_statistics_data'
    className: 'container'

    initialize: (options)->
      @statistics = options.statistics.bar_data

    templateHelpers: ->
      statistics: @statistics


  class UserShow.Statistics extends Marionette.LayoutView
    template: 'admin/users/show/templates/statistics'
    className: 'container'
    regions:
      statsGraph: '#graph'
      statsData: '#data'

    initialize: ->
      @init_date = moment().subtract(7, 'days').format("DD-MM-YYYY")
      @end_date = moment().format("DD-MM-YYYY")
      @group_by = "months"

    templateHelpers: ->
      init_date: @init_date
      end_date: @end_date

    ui:
      init_date: ".js-init-date"
      end_date: ".js-end-date"
      submit: ".js-submit"

    events:
      'click @ui.submit' : 'reloadStatistics'

    onRender: ->
      @ui.init_date.Zebra_DatePicker
        format: 'd-m-Y'
        show_icon: false
        view: 'years'
        default_position: 'below'
        show_clear_date: false
        show_select_today: false
        pair: @ui.end_date

      @ui.end_date.Zebra_DatePicker
        format: 'd-m-Y'
        show_icon: false
        view: 'years'
        default_position: 'below'
        show_clear_date: false

    onShow: ->
      data = { init_date: @init_date, end_date: @end_date, group_by: @group_by }
      @loadStatistics(data)

    loadStatistics: (data)->
      view = @
      Backbone.ajax
        url: AlumNet.api_endpoint + "/admin/users/#{@model.id}/statistics"
        data: data
        success: (data, response)->
          dataView = new UserShow.StatisticsData
            statistics: data
          graphView = new UserShow.StatisticsGraph
            statistics: data
          view.statsData.show(dataView)
          view.statsGraph.show(graphView)

    reloadStatistics: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(@)
      @init_date = data.init_date
      @end_date = data.end_date
      @group_by = data.group_by
      console.log data
      return unless @init_date != "" && @end_date != ""
      @loadStatistics(data)

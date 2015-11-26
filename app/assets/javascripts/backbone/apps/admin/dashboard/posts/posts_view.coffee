@AlumNet.module 'AdminApp.Dashboard.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->

  class Posts.BarGraph extends Marionette.ItemView
    template: 'admin/dashboard/posts/templates/_graph'
    className: 'container'

    ui:
      graph: '.js-graph'

    initialize: (options)->
      @statistics = options.statistics
      @layout = options.layout

    templateHelpers: ->
      interval: false

    onRender: ->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'BarChart',
        dataTable: @statistics.bar_data
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph.showAnimated(graph.render().el)

  class Posts.ColumnGraph extends Marionette.ItemView
    template: 'admin/dashboard/posts/templates/_graph'
    className: 'container'

    ui:
      graph: '.js-graph'

    events:
      'change [name=group_by]': 'changeGroupBy'

    initialize: (options)->
      @statistics = options.statistics
      @layout = options.layout

    templateHelpers: ->
      interval: true
      group_by: @layout.group_by

    onRender: ->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'ColumnChart',
        dataTable: @statistics.column_data
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph.showAnimated(graph.render().el)

    changeGroupBy: (e)->
      new_interval = $(e.currentTarget).val()
      @trigger 'change:interval', new_interval

  class Posts.Layout extends Marionette.LayoutView
    template: 'admin/dashboard/posts/templates/layout'
    className: 'container'
    regions:
      barGraph: '#bar-graph'
      columnGraph: '#column-graph'

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
      view.stopListening()
      Backbone.ajax
        url: AlumNet.api_endpoint + "/admin/stats/posts"
        data: data
        success: (data, response)->
          view.loadBarView(data)
          view.loadColumnView(data)

    reloadStatistics: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(@)
      @init_date = data.init_date
      @end_date = data.end_date
      data.group_by = @group_by
      return unless @init_date != "" && @end_date != ""
      @loadStatistics(data)

    loadBarView: (data)->
      barView = new Posts.BarGraph
        statistics: data
        layout: @
      @barGraph.show(barView)

    loadColumnView: (data)->
      columnView = new Posts.ColumnGraph
        statistics: data
        layout: @
      @listenTo(columnView, 'change:interval', @changeGroupBy)
      @columnGraph.show(columnView)

    changeGroupBy: (new_interval)->
      @group_by = new_interval
      data = { init_date: @init_date, end_date: @end_date, group_by: @group_by }
      @loadStatistics(data)
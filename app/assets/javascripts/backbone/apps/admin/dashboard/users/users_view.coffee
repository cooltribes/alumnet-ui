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
      chart_generation: '.chart_generation'
      chart_generation: '.chart_generation'
      chart_seniority: '.chart_seniority'
      chart_status: '.chart_status'


    initialize: (options)->
      @dates = options.dates


    templateHelpers: ()->
      start_date: @dates.start
      end_date: @dates.end


    onRender: () ->
      @ui.start_date.Zebra_DatePicker
        format: 'd-m-Y'
        show_icon: false
        view: 'years'
        default_position: 'below'
        show_clear_date: false
        show_select_today: false
        direction: [@dates.start, @dates.end]
        pair: @ui.end_date

      @ui.end_date.Zebra_DatePicker
        format: 'd-m-Y'
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


    _sortTableForChart: (dataTable)->

      values = dataTable.slice(1) #Get all but not the titles

      if values.length == 0
        $.growl.warning {message: "There is not data for these dates, try another query."}

      if @getInterval() == "days"

        values = _.sortBy values, (el)-> #Sort the arrays
          # return (new Date(el[0]))
          return (new Date(moment(el[0], "DD-MM-YYYY").format("MM-DD-YYYY")))
        # .reverse()

      else if @getInterval() == "months"
        values = _.sortBy values, (el)-> #Sort the arrays
          return (new Date("01-".concat(el[0])))

      else if @getInterval() == "years"
        values = _.sortBy values, (el)-> #Sort the arrays
          return (new Date(el[0])).getFullYear()

      [dataTable[0]].concat values #Build dataTable again with sorted values


    drawGraph: (dataTable)->

      dataTable = @_sortTableForChart(dataTable)

      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'AreaChart',
        dataTable: dataTable
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

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
          # 'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph_section.showAnimated(graph.render().el)


  class Users.ChartMap extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graphMap'

    ui:
      graph_section: ".js-graph"
      changeTypeBtn: ".js-changeType"

    modelEvents:
      "change:geo": "changeGeo"

    events:
      "click @ui.changeTypeBtn": "changeType"

    bindings:
      "[name=geo]": "geo"

    initialize:(options)->
      @model = new Backbone.Model
        geo: options.geo
        type: options.type #type 1:regist, 2:memb, 3:ltmemb, 4:total
        dataTable: []

    changeType: (e)->
      e.preventDefault()
      link = $(e.currentTarget)
      link.addClass("active")
      link.parent().siblings().find("a").removeClass("active")
      @model.set "type", link.attr("data-type")
      @drawGraph @model.get("dataTable")


    changeGeo: ->
      @trigger "changeGeo"

    getGeo: ->
      @model.get "geo"

    getType: ->
      @model.get "type"

    onRender: ->
      @stickit()

    drawAll: (dataTable)->
      @model.set "dataTable", dataTable
      @render()

      @drawGraph(dataTable)


    drawGraph: (dataTable)->
      newTable = []
      _.each dataTable, (country, index, table)->
        newTable[index] = [country[0], country[@model.get("type")]]
      ,
        @ #Context

      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'GeoChart',
        dataTable: newTable
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 468
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph_section.showAnimated(graph.render().el)


  class Users.ChartGeneration extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'BarChart',
        dataTable: dataTable
        options:
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph_section.showAnimated(graph.render().el)


  class Users.ChartSeniority extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'PieChart',
        dataTable: dataTable
        options:
          is3D: true
          # 'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph_section.showAnimated(graph.render().el)

  class Users.ChartGeneral extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"

    initialize: (options)->
      @typeOfChart = options.type

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: @typeOfChart
        dataTable: dataTable
        options:
          is3D: true
          # 'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          animation:
            duration: 1000
            easing: 'out'
            startup: true

      @ui.graph_section.showAnimated(graph.render().el)

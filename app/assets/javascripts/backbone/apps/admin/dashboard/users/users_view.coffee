@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Layout extends Marionette.LayoutView
    template: 'admin/dashboard/users/templates/layout'

    # ui:

    # events:
    #   'click .js-user-tabs a[rel]' : 'tabClicked'

    regions:
      chart_type_1: '.chart_type_1'
      chart_type_2: '.chart_type_2'

    # tabClicked: (e) ->
    #   tab_name = e.currentTarget.rel
    #   @ui.tab_elements.removeClass('active')
    #   $(e.currentTarget).parent().addClass('active')

    #   @trigger('tab_selected', tab_name)

  
  class Users.ChartType1 extends Marionette.ItemView
    template: 'admin/dashboard/users/templates/_graph'

    ui:
      graph_section: ".js-graph"

    drawGraph: (dataTable)->
      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'AreaChart',
        dataTable: dataTable
        # options:
        #   'title': 'Users'
        #   'legend': {'position': 'bottom', 'alignment':'center'}
        #   'height': 270
        #   'titleTextStyle': { 'fontSize': 16 }

      @ui.graph_section.showAnimated(graph.render().el)
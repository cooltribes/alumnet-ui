@AlumNet.module 'AdminApp.UserStats', (UserStats, @AlumNet, Backbone, Marionette, $, _) ->

  class UserStats.Layout extends Marionette.LayoutView
    template: 'admin/users/stats/view/templates/layout'

    ui:
      tab_elements: '.js-user-tabs li'

    events:
      'click .js-user-tabs a[rel]' : 'tabClicked'

    regions:
      tab_content_region: '.tab-content-region'

    tabClicked: (e) ->
      tab_name = e.currentTarget.rel
      @ui.tab_elements.removeClass('active')
      $(e.currentTarget).parent().addClass('active')

      @trigger('tab_selected', tab_name)

  
  class UserStats.GeneralGraph extends Marionette.ItemView
    template: 'admin/users/stats/view/templates/_graph'

    ui:
      graph_section: ".js-graph"

    modelEvents:
      "change": "modelChange"

    modelChange: (model)->
      users = model.get("users")
      members = model.get("members")
      lt_members = model.get("lt_members")

      graph = new AlumNet.Utilities.GoogleChart
        chartType: 'ColumnChart',
        dataTable: [
          ['Type of Users','Registrants', 'Members', 'LT Members'],
          ['Total Users', users, members, lt_members]
        ]
        options:
          'title': 'Users'
          'legend': {'position': 'bottom', 'alignment':'center'}
          'height': 270
          'titleTextStyle': { 'fontSize': 16 }


      @ui.graph_section.showAnimated(graph.render().el)

  class UserStats.RegionalGraph extends Marionette.ItemView
    template: 'admin/users/stats/view/templates/_graph'

    ui:
      graph_section: ".js-graph"
      selectRegion: "#js-residence-region"

    modelEvents:
      "change": "modelChange"
      "change:location_id": "modelChangeLocation"

    bindings:
      "#js-residence-region": "location_id"   


    modelChange: (model)->
      queryCounters = model.get("query_counters")

      if queryCounters?
        users = queryCounters.users
        members = queryCounters.members
        lt_members = queryCounters.lt_members

        graph = new AlumNet.Utilities.GoogleChart
          chartType: 'ColumnChart',
          dataTable: [
            ['Type of Users','Registrants', 'Members', 'LT Members'],
            ['Total Users', users, members, lt_members]
          ]
          options:
            'title': 'Users'
            'legend': {'position': 'bottom', 'alignment':'center'}
            'height': 270
            'titleTextStyle': { 'fontSize': 16 }

        @ui.graph_section.showAnimated(graph.render().el)

    onRender: ->

      if @model.get("canChange")
        data = AlumNet.request('get:regions:select2')
        @ui.selectRegion.select2
          placeholder: "Select a Region"
          data: data

        @ui.selectRegion.select2('val', @model.get('location_id')) 

        @stickit()     

    modelChangeLocation: (model)->
      model.set "q",
        profile_residence_country_region_id_eq: model.get "location_id"
      
      model.fetch
        data: 
          q: model.get("q")    

  class UserStats.NationalGraph extends Marionette.ItemView
    template: 'admin/users/stats/view/templates/_graph'

    ui:
      graph_section: ".js-graph"
      selectResidenceCountries: "#js-residence-countries"

    modelEvents:
      "change": "modelChange"
      "change:location_id": "modelChangeLocation"

    bindings:
      "#js-residence-countries": "location_id" 

  
    modelChange: (model)->
      # if !model.hasChanged("location_id")
      # console.log "model changed"
      # console.log model.previousAttributes()
      # console.log model.attributes
      queryCounters = model.get("query_counters")

      if queryCounters?
        users = queryCounters.users
        members = queryCounters.members
        lt_members = queryCounters.lt_members
        graph = new AlumNet.Utilities.GoogleChart
          chartType: 'ColumnChart',
          dataTable: [
            ['Type of Users','Registrants', 'Members', 'LT Members'],
            ['Total Users', users, members, lt_members]
          ]
          options:
            'title': 'Users'
            'legend': {'position': 'bottom', 'alignment':'center'}
            'height': 270
            'titleTextStyle': { 'fontSize': 16 }

        @ui.graph_section.showAnimated(graph.render().el)
        

    onRender: ->

      if @model.get("canChange")
        data = CountryList.toSelect2()
        @ui.selectResidenceCountries.select2
          placeholder: "Select a Country"
          data: data

        @ui.selectResidenceCountries.select2('val', @model.get('location_id')) 

        @stickit()     
      

    modelChangeLocation: (model)->
      model.set "q",
        profile_residence_country_id_eq: model.get "location_id"
      
      model.fetch
        data: 
          q: model.get("q")

  class UserStats.Graphics extends Marionette.CompositeView
    template: 'admin/users/stats/view/templates/graphics'

    initialize: (options) ->
      AlumNet.setTitle('Users Statistics')

    getChildView: (item)->
      type = item.get("graphType")
      if type == 0
        UserStats.GeneralGraph
      else if type == 1
        UserStats.RegionalGraph
      else if type == 2
        UserStats.NationalGraph

    childViewContainer: ".graphs-list"
    
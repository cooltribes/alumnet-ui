@AlumNet.module 'Shared.Views.Filters.Groups', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Type extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    template: '_shared/filters/groups/templates/type'

    initialize: (options)->          
      @model = new Backbone.Model
        all_selected: true
        title: options.title
      
      rows = [
        name: "Official"        
        value: true
      ,
        name: "Public"        
        value: false      
      ]
      
      @collection = new AlumNet.Entities.SearchFiltersCollection rows     

      @collection.on "checkStatus", @checkStatus, @
      
    
    buildQuery: (active_rows = [])->
      query = {}           

      if active_rows.length == 1        
        query =         
          term:
            official: active_rows[0].get "value"

      @trigger "search", query     


  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/groups/templates/layout'
    regions:
      locations: "#locations"
      type: "#type"      

    child_queries: [
      {}, {}, {}, {}
      ]  

    initialize: (options)->      

      searchable_fields = ["name", "description", "short_description"]
      type = "group"
      
      super _.extend options,
        searchable_fields: searchable_fields
        type: type                                        
      

    onRender: ->
      @locations_view = new AlumNet.Shared.Views.Filters.Shared.LocationContainer
        type: "other"

      @type_view = new Filters.Type
        title: "Type"
        
        
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      @type_view.on "search", (filter)->
        @updateChildQueries(filter, 1)
      , @  
      
      
      @locations.show(@locations_view)
      @type.show(@type_view)
      
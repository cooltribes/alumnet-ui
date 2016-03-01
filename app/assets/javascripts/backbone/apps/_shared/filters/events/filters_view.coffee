@AlumNet.module 'Shared.Views.Filters.Events', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Filters.Type extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    initialize: (options)->          
      @model = new Backbone.Model
        all_selected: true
        title: "Type"
        all_message: "All"
      
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


  class Filters.Condition extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    initialize: (options)->          
      @model = new Backbone.Model
        all_selected: true
        title: "Condition"
        all_message: "All"
      
      rows = [
        name: "Open" 
        value: "open"
      ,
        name: "Closed"        
        value: "closed"     
      ]
      
      @collection = new AlumNet.Entities.SearchFiltersCollection rows     

      @collection.on "checkStatus", @checkStatus, @
      
    
    buildQuery: (active_rows = [])->
      query = {}           

      if active_rows.length == 1        
        query =         
          match:
            event_type: active_rows[0].get "value"

      @trigger "search", query     


  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/events/templates/layout'
    regions:
      locations: "#locations"
      region_2: "#type"      
      region_3: "#condition"      


    child_queries: [
      {}
      ]  

    initialize: (options)->
      searchable_fields = ["name", "description"]
      type = "events"
      
      super _.extend options,
        searchable_fields: searchable_fields
        type: type                                        
      

    onRender: ->
      @locations_view = new AlumNet.Shared.Views.Filters.Shared.LocationContainer
        type: "other"
      
      @type_view = new Filters.Type
      @condition_view = new Filters.Condition
        
        
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      @type_view.on "search", (filter)->
        @updateChildQueries(filter, 1)
      , @  
      
      @condition_view.on "search", (filter)->
        @updateChildQueries(filter, 2)
      , @  
      
      
      @locations.show(@locations_view)
      @region_2.show(@type_view)
      @region_3.show(@condition_view)
      
@AlumNet.module 'Shared.Views.Filters.Events', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Filters.Type extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    initialize: (options)->                
      rows = [
        name: "Official"        
        value: true
      ,
        name: "Public"        
        value: false      
      ]
      
      @collection = new AlumNet.Entities.SearchFiltersCollection rows     

      @collection.on "checkStatus", @checkStatus, @

      #Call parent constructor and pass options for the view model.
      super
        title: "Type"       
      
    
    buildQuery: (active_rows = [])->
      query = {}           

      if active_rows.length == 1        
        query =         
          term:
            official: active_rows[0].get "value"

      @trigger "search", query


  class Filters.Condition extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    initialize: (options)->          
      rows = [
        name: "Open" 
        value: "open"
      ,
        name: "Closed"        
        value: "closed"     
      ]
      
      @collection = new AlumNet.Entities.SearchFiltersCollection rows     

      @collection.on "checkStatus", @checkStatus, @

      #Call parent constructor and pass options for the view model.
      super
        title: "Condition" 
      
    
    buildQuery: (active_rows = [])->
      query = {}           

      if active_rows.length == 1        
        query =         
          match:
            event_type: active_rows[0].get "value"

      @trigger "search", query     


  class Filters.Date extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    initialize: (options)->          
      rows = [
        name: "Upcoming" 
        value: "upcoming"
      ,
        name: "Past"        
        value: "past"     
      ,
        name: "Today"        
        value: "today"     
      ,
        name: "This Week"        
        value: "week"     
      ,
        name: "This Month"        
        value: "month"     
      ,
        name: "Next month"        
        value: "nextm"     
      ]
      
      @collection = new AlumNet.Entities.SearchFiltersCollection rows     

      @collection.on "checkStatus", @checkStatus, @

      #Call parent constructor and pass options for the view model.
      super
        title: "Date"     
         
    
    buildQuery: (active_rows = [])->
      query = {}           
      
      periods = active_rows.map (item)->
        
        value = item.get("value")
        
        if value == "upcoming"
          range = 
            gte: "now/d"

        else if value == "past"
          range = 
            lt: "now/d"

        else if value == "today"
          range = 
            lte: "now/d"
            gte: "now/d"

        else if value == "week"
          range = 
            lte: "now/w"
            gte: "now/w"            

        else if value == "month"
          range = 
            lte: "now/M"
            gte: "now/M"      

        else if value == "nextm"
          range = 
            lte: "now+1M/M"
            gte: "now+1M/M"      
          
        range =
          range:
            start_date: range 

      console.log periods

      query =
        bool:
          should: periods

      @trigger "search", query         

  
  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/events/templates/layout'
    regions:
      locations: "#locations"
      region_2: "#type"      
      region_3: "#condition"      
      region_4: "#date"      


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
      @date_view = new Filters.Date
        
        
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      @type_view.on "search", (filter)->
        @updateChildQueries(filter, 1)
      , @  
      
      @condition_view.on "search", (filter)->
        @updateChildQueries(filter, 2)
      , @  
      
      @date_view.on "search", (filter)->
        @updateChildQueries(filter, 3)
      , @  
      
      
      @locations.show(@locations_view)
      @region_2.show(@type_view)
      @region_3.show(@condition_view)
      @region_4.show(@date_view)
      

      ###
        All
        Upcoming
        Past
        Today
        This week
        This month
        Next month

      ###
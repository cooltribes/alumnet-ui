@AlumNet.module 'Shared.Views.Filters.Groups', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Condition extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    template: '_shared/filters/groups/templates/condition'

    initialize: (options)->          
      @model = new Backbone.Model
        all_selected: true
      
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
      personalFilters = []

      gender = _.filter active_rows, (el)->
        el.get("type") == "gender"
      
      age_ranges = _.filter active_rows, (el)->
        el.get("type") == "age"
      
      if gender.length == 1 #because only one gender will affect the response, both is the same as no gender filter
        personalFilters.push
          match:
            gender: gender[0].get("value")
      
      if age_ranges.length > 0                 
        ranges = []
        _.each age_ranges, (model, i)->           
          bounds = model.get("value").split("-")         
          ranges.push
            range:
              age: 
                gte: bounds[0]
                lte: bounds[1]

        personalFilters.push
          bool:
            should: ranges

      query =         
        bool:
          must: personalFilters

      @trigger "search", query     


  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/groups/templates/layout'
    regions:
      locations: "#locations"
      personal: "#personal"
      skills: "#skills"
      languages: "#languages"

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
        
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      
      @locations.show(@locations_view)
      